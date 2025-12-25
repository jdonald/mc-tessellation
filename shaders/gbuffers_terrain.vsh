#version 150 compatibility

// Vertex Shader for Terrain - Tessellation Shader Pack
// Prepares vertex data for geometry shader tessellation

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 normal;

void main() {
    // Pass through texture coordinates
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    // Pass through lightmap coordinates
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    // Pass through vertex color (for biome tinting, etc.)
    glcolor = gl_Color;

    // Calculate normal in view space
    normal = normalize(gl_NormalMatrix * gl_Normal);

    // Pass position to geometry shader
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
