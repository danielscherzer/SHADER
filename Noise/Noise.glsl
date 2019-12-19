#version 330

uniform vec2 u_resolution;
uniform float iGlobalTime;
uniform vec3 iMouse;

const float PI = 3.1415926535897932384626433832795;
const float TWOPI = 2 * PI;
const float EPSILON = 10e-4;

float quad(vec2 coord, vec2 lowerLeft, vec2 size)
{
	vec2 a = step(lowerLeft, coord);
	vec2 b = 1 - step(lowerLeft + size, coord);
	return a.x * b.x * a.y * b.y;
}

float rand(float seed)
{
	return fract(sin(seed) * 1231534.9);
}

//value noise: random values at integer positions with interpolation in-between
float noise(float u)
{
	float i = floor(u); // integer position

	//random value at nearest integer positions
	float v0 = rand(i);
	float v1 = rand(i + 1);

	float f = fract(u);
	float weight = f; // linear interpolation
//	weight = smoothstep(0, 1, f); // step 2 cubic interpolation

	return mix(v0, v1, weight);
}

//gradient noise: random gradient at integer positions with interpolation in-between
float gnoise(float u)
{
	float i = floor(u); // integer position
	
	//random gradient at nearest integer positions
	float g0 = 2 * rand(i) - 1; // gradient_0
	float g1 = 2 * rand(i + 1) - 1; // gradient_1

	float f = fract(u);
	float v0 = dot(g0, f);
	float v1 = dot(g1, f - 1);
	
	float weight = f; // linear interpolation
//	weight = smoothstep(0, 1, f); // step 4 cubic interpolation

	return mix(v0, v1, weight) + 0.5;
}

void main() {
	//coordinates in range [0,1]
    vec2 coord = gl_FragCoord.xy/u_resolution;
	
	vec2 mouse = iMouse.xy / u_resolution;
	mouse *= 20;
	
	coord *= 10.0;
	float value = rand(coord.x - mouse.x); //cannot control frequency
//	 value = noise(coord.x - mouse.x); // step 1 can control frequency
//	 value = gnoise(coord.x - mouse.x); // step 3 
	
	const vec3 white = vec3(1);
	vec3 color = value * white;
		
    gl_FragColor = vec4(color, 1.0);
}
