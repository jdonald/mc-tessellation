#version 150 compatibility

// Final Shader - Last pass before display

uniform sampler2D colortex0;

in vec2 texcoord;

out vec4 fragColor;

void main() {
    // Final color output
    vec4 color = texture2D(colortex0, texcoord);

    // Apply any final color correction if needed
    fragColor = color;
}
