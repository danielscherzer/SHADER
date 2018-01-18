#version 330

#include "../libs/Noise.glsl"

uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;

//fractal Brownian motion
float fBm(vec2 coord) 
{
	int octaves = 6;
    float value = 0;
    float amplitude = 0.5;
	float lacunarity = 2;
	float gain = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), 
                    -sin(0.5), cos(0.5));
    for (int i = 0; i < octaves; ++i) {
        value += amplitude * gnoise(coord);
        coord = rot * coord * lacunarity + shift;
        amplitude *= gain;
    }
    return value;
}

void main() 
{
    vec2 st = gl_FragCoord.xy/iResolution;
	st *= 10;

    float fBmCoord = fBm(st);
	float fBmfBm = fBm(fBmCoord + st + 0.15 * iGlobalTime);
    float f = fBm(st + fBmfBm); // form is fBm(coord + fBm(fBm(coord) + coord + t))

    vec3 color = vec3(1.0);
    // color = mix(vec3(0.1, 0.62, 0.67), vec3(0.67, 0.67, 0.5), clamp(f, 0, 1));
    // color = mix(color, vec3(0 , 0 , 0.16), clamp(fBmCoord, 0.0, 1.0));
    // color = mix(color, vec3(0.67, 1, 1), clamp(fBmfBm,0.0,1.0));

    gl_FragColor = vec4((f * f * f + 0.2 * f * f + 0.5 * f) * color, 1);
}
