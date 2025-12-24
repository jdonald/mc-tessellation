#version 150 compatibility

// Composite Shader - Post-processing pass
// Can be used for additional effects like edge enhancement to make triangles more visible

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform vec2 texelSize;

in vec2 texcoord;

out vec4 fragColor;

void main() {
    // Sample the rendered scene
    vec4 color = texture2D(colortex0, texcoord);

    // Simple pass-through for now
    // Could add edge detection here to emphasize triangle edges

    fragColor = color;
}
