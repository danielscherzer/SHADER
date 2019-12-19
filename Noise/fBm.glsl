#version 330

#include "../libs/Noise.glsl"

uniform vec3 iMouse;
uniform vec2 u_resolution;
uniform float iGlobalTime;

//fractal Brownian motion
float fBm(float x)
{
	// Properties
	int octaves = 1;//int(iMouse.x * 0.01);
	float lacunarity = 2;
	float gain = 0.5;
	// Initial values
	float amplitude = 1;
	float frequency = 1;
	float value = 0;
	// Loop of octaves
	for (int i = 0; i < octaves; ++i)
	{
		value += amplitude * noise(frequency * x);
		frequency *= lacunarity;
		amplitude *= gain;
	}
	return value;
}

//draw function line
float plotFunction(vec2 coord, float width)
{
	float dist = abs(fBm(coord.x) - coord.y);
	return 1 - smoothstep(0, width, dist);
}

out vec3 color;
void main() {
	//map coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/u_resolution;
	//setup coordinate system
	coord = (coord - 0.5) * vec2(10, 4);
	//draw function
	float graph = plotFunction(coord, 0.03);
	color = vec3(1) * graph;
}
