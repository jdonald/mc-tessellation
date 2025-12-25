#version 150 compatibility

// Fragment Shader for Entities - No tessellation, just basic rendering

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 normal;

uniform sampler2D texture;
uniform sampler2D lightmap;

out vec4 fragColor;

void main() {
    vec4 color = texture2D(texture, texcoord) * glcolor;

    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    float diffuse = max(dot(normal, lightDir), 0.0);
    float ambient = 0.5;
    float lighting = ambient + diffuse * 0.5;

    color.rgb *= lighting;

    vec4 lightmapColor = texture2D(lightmap, lmcoord);
    color.rgb *= lightmapColor.rgb;

    fragColor = color;
}
