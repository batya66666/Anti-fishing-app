#version 460 core
#include <flutter/runtime_effect.glsl>

// Tears apart a snapshot of the screen: displaced bands, RGB split, scanlines, noise and spreading red.
uniform vec2 uSize;
uniform float uTime;
uniform float uIntensity;
uniform sampler2D uTexture;

out vec4 fragColor;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    float i = clamp(uIntensity, 0.0, 1.0);
    float frame = floor(uTime * 22.0);

    // Horizontal bands jump sideways. Some frames are much worse than others.
    float bands = mix(14.0, 42.0, rand(vec2(frame, 3.0)));
    float band = floor(uv.y * bands);
    float jump = step(1.0 - 0.75 * i, rand(vec2(band, frame)));
    float shift = (rand(vec2(band * 1.7, frame * 0.5)) - 0.5) * jump * 0.42 * i;

    // Fine analogue wobble over the whole picture.
    float wobble = sin(uv.y * 90.0 + uTime * 40.0) * 0.003 * i;
    vec2 p = vec2(uv.x + shift + wobble, uv.y);
    p.x = fract(p.x);

    // Colour channels drift apart.
    float split = (0.006 + 0.03 * rand(vec2(frame, 9.0))) * i;
    float r = texture(uTexture, vec2(fract(p.x + split), p.y)).r;
    float g = texture(uTexture, p).g;
    float b = texture(uTexture, vec2(fract(p.x - split), p.y)).b;
    vec3 color = vec3(r, g, b);

    // Scanlines and salt noise.
    color *= 1.0 - 0.28 * i * (0.5 + 0.5 * sin(uv.y * uSize.y * 1.6));
    float noise = rand(uv * vec2(frame + 1.0, 7.0));
    color = mix(color, vec3(noise), 0.16 * i);

    // Dead blocks: rectangles of the picture fail completely.
    vec2 cell = floor(uv * vec2(12.0, 26.0));
    float dead = step(1.0 - 0.14 * i * i, rand(cell + frame));
    color = mix(color, vec3(rand(cell), 0.0, 0.05), dead);

    // Red bleeds in as the screen dies.
    float luma = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 red = vec3(luma * 1.25 + 0.14, luma * 0.1, luma * 0.12);
    color = mix(color, red, smoothstep(0.35, 1.0, i));

    fragColor = vec4(color, 1.0);
}
