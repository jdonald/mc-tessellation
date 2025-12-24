#version 150 compatibility

// Vertex Shader for Textured Geometry - Tessellation Shader Pack

out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out vec3 worldPos;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;

    vec4 viewPos = gbufferModelView * gl_Vertex;
    worldPos = (gbufferModelViewInverse * viewPos).xyz;

    normal = normalize(gl_NormalMatrix * gl_Normal);

    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
