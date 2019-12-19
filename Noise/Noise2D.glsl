#version 330
//idea from http://thebookofshaders.com/edit.php#09/marching_dots.frag

float quinticInterpolation(float x)
{
	return x*x*x*(x*(x*6.-15.)+10.);
}


vec2 quinticInterpolation(vec2 value)
{
	return vec2(quinticInterpolation(value.x), quinticInterpolation(value.y));
}

float rand(float seed)
{
	return fract(sin(seed) * 1231534.9);
}

float rand(vec2 seed) { 
    return rand(dot(seed, vec2(12.9898, 783.233)));
}

//random vector with length 1
vec2 rand2(vec2 seed)
{
	const float pi = 3.1415926535897932384626433832795;
	const float twopi = 2 * pi;
	float r = rand(seed) * twopi;
	return vec2(cos(r), sin(r));
}

//value noise: random values at integer positions with interpolation inbetween
float noise(vec2 coord)
{
	vec2 i = floor(coord); // integer position

	//random value at nearest integer positions
	float v00 = rand(i);
	float v10 = rand(i + vec2(1, 0));
	float v01 = rand(i + vec2(0, 1));
	float v11 = rand(i + vec2(1, 1));
	
	vec2 f = fract(coord);
	vec2 weight = f; // linear interpolation
//	weight = smoothstep(0, 1, f); // cubic interpolation
//	weight = quinticInterpolation(f);

	float x1 = mix(v00, v10, weight.x);
	float x2 = mix(v01, v11, weight.x);
	return mix(x1, x2, weight.y);
}

//gradient noise: random gradient at integer positions with interpolation inbetween
float gnoise(vec2 coord)
{
	vec2 i = floor(coord); // integer position

	//random gradient at nearest integer positions
	vec2 g00 = rand2(i);
	vec2 g10 = rand2(i + vec2(1, 0));
	vec2 g01 = rand2(i + vec2(0, 1));
	vec2 g11 = rand2(i + vec2(1, 1));

	vec2 f = fract(coord);
	float v00 = dot(g00, f);
	float v10 = dot(g10, f - vec2(1, 0));
	float v01 = dot(g01, f - vec2(0, 1));
	float v11 = dot(g11, f - vec2(1, 1));

	vec2 weight = f; // linear interpolation
//	weight = smoothstep(0, 1, f); // cubic interpolation
//	weight = smoothstep(0, 1, weight); // x^6 interpolation
//	weight = quinticInterpolation(f);

	float x1 = mix(v00, v10, weight.x);
	float x2 = mix(v01, v11, weight.x);
	return mix(x1, x2, weight.y) + 0.5;
}

uniform vec2 u_resolution;
uniform float iGlobalTime;
uniform vec3 iMouse;

out vec3 color;
void main() {
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/u_resolution;
	
	float value = rand(coord);
//	value = noise(coord * 10);
//	value = gnoise(coord * 10);
	
	color = vec3(1) * value;
}
