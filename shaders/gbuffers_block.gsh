#version 150 compatibility

// Geometry Shader for Textured Geometry - Lighter tessellation for non-terrain

layout(triangles) in;
layout(triangle_strip, max_vertices = 64) out;

in vec2 texcoord[];
in vec4 glcolor[];
in vec3 normal[];
in vec3 worldPos[];

out vec2 texcoordOut;
out vec4 glcolorOut;
out vec3 normalOut;
out float ao;

#ifndef TESSELLATION_LEVEL
#define TESSELLATION_LEVEL 2
#endif

#ifndef TESSELLATION_SMOOTHNESS
#define TESSELLATION_SMOOTHNESS 0.5
#endif

void emitVertex(vec4 pos, vec2 tc, vec4 col, vec3 norm, float ambientOcclusion) {
    gl_Position = pos;
    texcoordOut = tc;
    glcolorOut = col;
    normalOut = norm;
    ao = ambientOcclusion;
    EmitVertex();
}

void subdivideTri(vec4 v0, vec4 v1, vec4 v2,
                  vec2 t0, vec2 t1, vec2 t2,
                  vec4 c0, vec4 c1, vec4 c2,
                  vec3 n0, vec3 n1, vec3 n2,
                  int depth) {

    if (depth <= 0) {
        emitVertex(v0, t0, c0, n0, 1.0);
        emitVertex(v1, t1, c1, n1, 1.0);
        emitVertex(v2, t2, c2, n2, 1.0);
        EndPrimitive();
        return;
    }

    vec4 v01 = (v0 + v1) * 0.5;
    vec4 v12 = (v1 + v2) * 0.5;
    vec4 v20 = (v2 + v0) * 0.5;

    vec2 t01 = (t0 + t1) * 0.5;
    vec2 t12 = (t1 + t2) * 0.5;
    vec2 t20 = (t2 + t0) * 0.5;

    vec4 c01 = (c0 + c1) * 0.5;
    vec4 c12 = (c1 + c2) * 0.5;
    vec4 c20 = (c2 + c0) * 0.5;

    vec3 n01 = normalize(n0 + n1);
    vec3 n12 = normalize(n1 + n2);
    vec3 n20 = normalize(n2 + n0);

    // Less displacement for non-terrain objects
    float displacementAmount = TESSELLATION_SMOOTHNESS * 0.05;
    v01.xyz += n01 * displacementAmount;
    v12.xyz += n12 * displacementAmount;
    v20.xyz += n20 * displacementAmount;

    subdivideTri(v0, v01, v20, t0, t01, t20, c0, c01, c20, n0, n01, n20, depth - 1);
    subdivideTri(v1, v12, v01, t1, t12, t01, c1, c12, c01, n1, n12, n01, depth - 1);
    subdivideTri(v2, v20, v12, t2, t20, t12, c2, c20, c12, n2, n20, n12, depth - 1);
    subdivideTri(v01, v12, v20, t01, t12, t20, c01, c12, c20, n01, n12, n20, depth - 1);
}

void main() {
    // Use lower tessellation level for non-terrain (1 instead of 2)
    int tessDepth = max(TESSELLATION_LEVEL - 2, 0);

    if (tessDepth < 1) {
        emitVertex(gl_in[0].gl_Position, texcoord[0], glcolor[0], normal[0], 1.0);
        emitVertex(gl_in[1].gl_Position, texcoord[1], glcolor[1], normal[1], 1.0);
        emitVertex(gl_in[2].gl_Position, texcoord[2], glcolor[2], normal[2], 1.0);
        EndPrimitive();
    } else {
        subdivideTri(
            gl_in[0].gl_Position, gl_in[1].gl_Position, gl_in[2].gl_Position,
            texcoord[0], texcoord[1], texcoord[2],
            glcolor[0], glcolor[1], glcolor[2],
            normal[0], normal[1], normal[2],
            tessDepth
        );
    }
}
