#version 150 compatibility

// Geometry Shader for Terrain - Tessellation Shader Pack
// Subdivides triangles to create tessellated, rounded surfaces

layout(triangles) in;
layout(triangle_strip, max_vertices = 64) out;

// Input from vertex shader
in vec2 texcoord[];
in vec2 lmcoord[];
in vec4 glcolor[];
in vec3 normal[];

// Output to fragment shader
out vec2 texcoordOut;
out vec2 lmcoordOut;
out vec4 glcolorOut;
out vec3 normalOut;

// Configurable tessellation settings
#ifndef TESSELLATION_LEVEL
#define TESSELLATION_LEVEL 2
#endif

#ifndef TESSELLATION_SMOOTHNESS
#define TESSELLATION_SMOOTHNESS 0.5
#endif

uniform mat4 gbufferProjection;

// Interpolate vertex attributes
vec4 interpolateVertex(int i, int j, float t) {
    return mix(gl_in[i].gl_Position, gl_in[j].gl_Position, t);
}

vec2 interpolateTexcoord(int i, int j, float t) {
    return mix(texcoord[i], texcoord[j], t);
}

vec4 interpolateColor(int i, int j, float t) {
    return mix(glcolor[i], glcolor[j], t);
}

vec3 interpolateNormal(int i, int j, float t) {
    return normalize(mix(normal[i], normal[j], t));
}

// Calculate displacement for tessellated vertices
// This creates the "rounded" effect while keeping triangles visible
vec3 calculateDisplacement(vec3 pos, vec3 norm, float edgeFactor) {
    // Displace along normal direction
    // edgeFactor is 0 at original vertices, higher at edge midpoints
    // This creates a spherical/rounded appearance
    float displacement = edgeFactor * TESSELLATION_SMOOTHNESS * 0.15;
    return norm * displacement;
}

// Emit a single vertex with all attributes
void emitVertex(vec4 pos, vec2 tc, vec2 lm, vec4 col, vec3 norm) {
    gl_Position = pos;
    texcoordOut = tc;
    lmcoordOut = lm;
    glcolorOut = col;
    normalOut = norm;
    EmitVertex();
}

// Subdivide a triangle recursively
void subdivideTri(vec4 v0, vec4 v1, vec4 v2,
                  vec2 t0, vec2 t1, vec2 t2,
                  vec2 l0, vec2 l1, vec2 l2,
                  vec4 c0, vec4 c1, vec4 c2,
                  vec3 n0, vec3 n1, vec3 n2,
                  int depth) {

    if (depth <= 0) {
        // Base case: emit the triangle
        emitVertex(v0, t0, l0, c0, n0);
        emitVertex(v1, t1, l1, c1, n1);
        emitVertex(v2, t2, l2, c2, n2);
        EndPrimitive();
        return;
    }

    // Calculate midpoints
    vec4 v01 = (v0 + v1) * 0.5;
    vec4 v12 = (v1 + v2) * 0.5;
    vec4 v20 = (v2 + v0) * 0.5;

    vec2 t01 = (t0 + t1) * 0.5;
    vec2 t12 = (t1 + t2) * 0.5;
    vec2 t20 = (t2 + t0) * 0.5;

    vec2 l01 = (l0 + l1) * 0.5;
    vec2 l12 = (l1 + l2) * 0.5;
    vec2 l20 = (l2 + l0) * 0.5;

    vec4 c01 = (c0 + c1) * 0.5;
    vec4 c12 = (c1 + c2) * 0.5;
    vec4 c20 = (c2 + c0) * 0.5;

    vec3 n01 = normalize(n0 + n1);
    vec3 n12 = normalize(n1 + n2);
    vec3 n20 = normalize(n2 + n0);

    // Apply displacement to midpoints for rounding effect
    float displacementAmount = TESSELLATION_SMOOTHNESS * 0.08;
    v01.xyz += n01 * displacementAmount;
    v12.xyz += n12 * displacementAmount;
    v20.xyz += n20 * displacementAmount;

    // Recursively subdivide into 4 triangles
    subdivideTri(v0, v01, v20, t0, t01, t20, l0, l01, l20, c0, c01, c20, n0, n01, n20, depth - 1);
    subdivideTri(v1, v12, v01, t1, t12, t01, l1, l12, l01, c1, c12, c01, n1, n12, n01, depth - 1);
    subdivideTri(v2, v20, v12, t2, t20, t12, l2, l20, l12, c2, c20, c12, n2, n20, n12, depth - 1);
    subdivideTri(v01, v12, v20, t01, t12, t20, l01, l12, l20, c01, c12, c20, n01, n12, n20, depth - 1);
}

void main() {
    // Determine tessellation depth based on settings
    int tessDepth = TESSELLATION_LEVEL - 1;

    // Check if triangle is too small to tessellate (far away or edge-on)
    vec3 screenPos0 = gl_in[0].gl_Position.xyz / gl_in[0].gl_Position.w;
    vec3 screenPos1 = gl_in[1].gl_Position.xyz / gl_in[1].gl_Position.w;
    vec3 screenPos2 = gl_in[2].gl_Position.xyz / gl_in[2].gl_Position.w;

    float area = length(cross(screenPos1 - screenPos0, screenPos2 - screenPos0));

    // Skip tessellation for very small triangles (LOD)
    if (area < 0.001 || tessDepth < 1) {
        // Just pass through original triangle
        emitVertex(gl_in[0].gl_Position, texcoord[0], lmcoord[0], glcolor[0], normal[0]);
        emitVertex(gl_in[1].gl_Position, texcoord[1], lmcoord[1], glcolor[1], normal[1]);
        emitVertex(gl_in[2].gl_Position, texcoord[2], lmcoord[2], glcolor[2], normal[2]);
        EndPrimitive();
    } else {
        // Tessellate the triangle
        subdivideTri(
            gl_in[0].gl_Position, gl_in[1].gl_Position, gl_in[2].gl_Position,
            texcoord[0], texcoord[1], texcoord[2],
            lmcoord[0], lmcoord[1], lmcoord[2],
            glcolor[0], glcolor[1], glcolor[2],
            normal[0], normal[1], normal[2],
            tessDepth
        );
    }
}
