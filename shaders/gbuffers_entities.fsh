#version 150 compatibility

// Fragment Shader for Entities - No tessellation, just basic rendering

in vec2 texcoordOut;
in vec2 lmcoordOut;
in vec4 glcolorOut;
in vec3 normalOut;

uniform sampler2D texture;
uniform sampler2D lightmap;

out vec4 fragColor;

void main() {
    vec4 color = texture2D(texture, texcoordOut) * glcolorOut;

    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    float diffuse = max(dot(normalOut, lightDir), 0.0);
    float ambient = 0.5;
    float lighting = ambient + diffuse * 0.5;

    color.rgb *= lighting;

    vec4 lightmapColor = texture2D(lightmap, lmcoordOut);
    color.rgb *= lightmapColor.rgb;

    fragColor = color;
}
