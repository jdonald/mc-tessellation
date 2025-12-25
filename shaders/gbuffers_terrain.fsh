#version 150 compatibility

// Fragment Shader for Terrain - Tessellation Shader Pack
// Handles final shading of tessellated surfaces

in vec2 texcoordOut;
in vec2 lmcoordOut;
in vec4 glcolorOut;
in vec3 normalOut;

uniform sampler2D texture;
uniform sampler2D lightmap;

out vec4 fragColor;

void main() {
    // Sample the block texture
    vec4 color = texture2D(texture, texcoordOut) * glcolorOut;

    // Apply basic lighting based on normal for tessellation effect
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    float diffuse = max(dot(normalOut, lightDir), 0.0);
    float ambient = 0.4;
    float lighting = ambient + diffuse * 0.6;

    color.rgb *= lighting;

    // Apply Minecraft's lightmap
    vec4 lightmapColor = texture2D(lightmap, lmcoordOut);
    color.rgb *= lightmapColor.rgb;

    // Output final color
    fragColor = color;
}
