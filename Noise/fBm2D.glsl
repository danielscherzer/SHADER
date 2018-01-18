#version 330

#include "../libs/Noise.glsl"

uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;

float absNoise(vec2 coord)
{
	return abs((gnoise(coord) - 0.5) * 2);
}

float ridgeNoise(vec2 coord)
{
	float a = 1 - absNoise(coord);
	return pow(a, 4);
}

//fractal Brownian motion
float fBm(vec2 coord)
{
	// Properties
	int octaves = 6;
	float lacunarity = 2;
	float gain = 0.5;
	// Initial values
	float amplitude = 0.5;
	float value = 0;
	// Loop of octaves
	for (int i = 0; i < octaves; ++i)
	{
		value += amplitude * noise(coord + iGlobalTime);
		// value += amplitude * absNoise(coord + iGlobalTime); //turbulence
		// value += amplitude * ridgeNoise(coord + iGlobalTime); //ridge
		coord *= lacunarity;
		amplitude *= gain;
	}
	return value;
}

void main() {
    vec2 st = gl_FragCoord.xy/iResolution;
    st.x *= iResolution.x/iResolution.y;

    vec3 color = vec3(0.0);
    color += fBm(10 * st);

    gl_FragColor = vec4(color,1.0);
}
