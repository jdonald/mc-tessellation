#version 150 compatibility

// Fragment Shader for Terrain - Tessellation Shader Pack
// Handles final shading of tessellated surfaces

in vec2 texcoordOut;
in vec4 glcolorOut;
in vec3 normalOut;
in float ao;

uniform sampler2D texture;
uniform sampler2D lightmap;

out vec4 fragColor;

void main() {
    // Sample the block texture
    vec4 color = texture2D(texture, texcoordOut) * glcolorOut;

    // Apply basic lighting based on normal
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    float diffuse = max(dot(normalOut, lightDir), 0.0);
    float ambient = 0.4;
    float lighting = ambient + diffuse * 0.6;

    // Apply lighting
    color.rgb *= lighting;

    // Apply ambient occlusion from tessellation
    color.rgb *= ao;

    // Apply Minecraft's lightmap
    vec2 lmcoord = vec2(0.5, 0.9);
    vec4 lightmapColor = texture2D(lightmap, lmcoord);
    color.rgb *= lightmapColor.rgb;

    // Output final color
    fragColor = color;
}
