#version 150 compatibility

// Vertex Shader for Terrain - Tessellation Shader Pack
// Prepares vertex data for geometry shader tessellation

out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out vec3 worldPos;
out float blockId;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

void main() {
    // Pass through texture coordinates
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    // Pass through vertex color (for biome tinting, etc.)
    glcolor = gl_Color;

    // Calculate world-space position for the geometry shader
    vec4 viewPos = gbufferModelView * gl_Vertex;
    worldPos = (gbufferModelViewInverse * viewPos).xyz;

    // Calculate normal in view space
    normal = normalize(gl_NormalMatrix * gl_Normal);

    // Store block ID approximation based on texture coordinates
    // This helps the geometry shader make decisions about tessellation
    blockId = gl_MultiTexCoord0.z;

    // Pass position to geometry shader
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
