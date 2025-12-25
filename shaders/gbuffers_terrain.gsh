#version 150 compatibility

// Geometry Shader for Terrain - Tessellation Shader Pack
// Subdivides triangles to create tessellated, rounded surfaces

layout(triangles) in;
layout(triangle_strip, max_vertices = 256) out;

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

struct Tri {
    vec4 v[3];
    vec3 n[3];
    vec3 b[3]; // Barycentric coordinates
    int depth;
};

void emitVertex(vec4 pos, vec3 norm, vec3 bary) {
    gl_Position = pos;
    texcoordOut = texcoord[0] * bary.x + texcoord[1] * bary.y + texcoord[2] * bary.z;
    lmcoordOut = lmcoord[0] * bary.x + lmcoord[1] * bary.y + lmcoord[2] * bary.z;
    glcolorOut = glcolor[0] * bary.x + glcolor[1] * bary.y + glcolor[2] * bary.z;
    normalOut = norm;
    EmitVertex();
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
        emitVertex(gl_in[0].gl_Position, normal[0], vec3(1,0,0));
        emitVertex(gl_in[1].gl_Position, normal[1], vec3(0,1,0));
        emitVertex(gl_in[2].gl_Position, normal[2], vec3(0,0,1));
        EndPrimitive();
        return;
    }

    // Stack for iterative subdivision
    Tri stack[12];
    int stackTop = 0;

    // Push initial triangle
    stack[stackTop].v[0] = gl_in[0].gl_Position;
    stack[stackTop].v[1] = gl_in[1].gl_Position;
    stack[stackTop].v[2] = gl_in[2].gl_Position;
    stack[stackTop].n[0] = normal[0];
    stack[stackTop].n[1] = normal[1];
    stack[stackTop].n[2] = normal[2];
    stack[stackTop].b[0] = vec3(1, 0, 0);
    stack[stackTop].b[1] = vec3(0, 1, 0);
    stack[stackTop].b[2] = vec3(0, 0, 1);
    stack[stackTop].depth = tessDepth;
    stackTop++;

    while (stackTop > 0) {
        stackTop--;
        Tri curr = stack[stackTop];

        if (curr.depth <= 0) {
            emitVertex(curr.v[0], curr.n[0], curr.b[0]);
            emitVertex(curr.v[1], curr.n[1], curr.b[1]);
            emitVertex(curr.v[2], curr.n[2], curr.b[2]);
            EndPrimitive();
            continue;
        }

        // Calculate midpoints
        vec4 v01 = (curr.v[0] + curr.v[1]) * 0.5;
        vec4 v12 = (curr.v[1] + curr.v[2]) * 0.5;
        vec4 v20 = (curr.v[2] + curr.v[0]) * 0.5;

        vec3 n01 = normalize(curr.n[0] + curr.n[1]);
        vec3 n12 = normalize(curr.n[1] + curr.n[2]);
        vec3 n20 = normalize(curr.n[2] + curr.n[0]);

        vec3 b01 = (curr.b[0] + curr.b[1]) * 0.5;
        vec3 b12 = (curr.b[1] + curr.b[2]) * 0.5;
        vec3 b20 = (curr.b[2] + curr.b[0]) * 0.5;

        // Apply displacement (higher for terrain)
        float displacementAmount = TESSELLATION_SMOOTHNESS * 0.08;
        v01.xyz += n01 * displacementAmount;
        v12.xyz += n12 * displacementAmount;
        v20.xyz += n20 * displacementAmount;

        int nextDepth = curr.depth - 1;

        // Push children
        
        // Child 4 (Center)
        stack[stackTop].v[0] = v01; stack[stackTop].v[1] = v12; stack[stackTop].v[2] = v20;
        stack[stackTop].n[0] = n01; stack[stackTop].n[1] = n12; stack[stackTop].n[2] = n20;
        stack[stackTop].b[0] = b01; stack[stackTop].b[1] = b12; stack[stackTop].b[2] = b20;
        stack[stackTop].depth = nextDepth;
        stackTop++;

        // Child 3
        stack[stackTop].v[0] = curr.v[2]; stack[stackTop].v[1] = v20; stack[stackTop].v[2] = v12;
        stack[stackTop].n[0] = curr.n[2]; stack[stackTop].n[1] = n20; stack[stackTop].n[2] = n12;
        stack[stackTop].b[0] = curr.b[2]; stack[stackTop].b[1] = b20; stack[stackTop].b[2] = b12;
        stack[stackTop].depth = nextDepth;
        stackTop++;

        // Child 2
        stack[stackTop].v[0] = curr.v[1]; stack[stackTop].v[1] = v12; stack[stackTop].v[2] = v01;
        stack[stackTop].n[0] = curr.n[1]; stack[stackTop].n[1] = n12; stack[stackTop].n[2] = n01;
        stack[stackTop].b[0] = curr.b[1]; stack[stackTop].b[1] = b12; stack[stackTop].b[2] = b01;
        stack[stackTop].depth = nextDepth;
        stackTop++;

        // Child 1
        stack[stackTop].v[0] = curr.v[0]; stack[stackTop].v[1] = v01; stack[stackTop].v[2] = v20;
        stack[stackTop].n[0] = curr.n[0]; stack[stackTop].n[1] = n01; stack[stackTop].n[2] = n20;
        stack[stackTop].b[0] = curr.b[0]; stack[stackTop].b[1] = b01; stack[stackTop].b[2] = b20;
        stack[stackTop].depth = nextDepth;
        stackTop++;
    }
}