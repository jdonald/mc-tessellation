#version 150 compatibility

// Vertex Shader for Entities - Minimal tessellation for mobs/entities

out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
    normal = normalize(gl_NormalMatrix * gl_Normal);
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
