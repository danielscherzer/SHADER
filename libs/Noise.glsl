#ifndef noise_glsl
#define noise_glsl

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
float noise(float u)
{
	float i = floor(u); // integer position

	//random value at nearest integer positions
	float v0 = rand(i);
	float v1 = rand(i + 1);

	float f = fract(u);
	float weight = f; // linear interpolation
	// weight = smoothstep(0, 1, f); // cubic interpolation
	// weight = quinticInterpolation(f);

	return mix(v0, v1, weight);
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
	weight = smoothstep(0, 1, f); // cubic interpolation
	weight = quinticInterpolation(f);

	float x1 = mix(v00, v10, weight.x);
	float x2 = mix(v01, v11, weight.x);
	return mix(x1, x2, weight.y);
}

//gradient noise: random gradient at integer positions with interpolation inbetween
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
	weight = smoothstep(0, 1, f); // cubic interpolation
	weight = quinticInterpolation(f);

	return mix(v0, v1, weight) + 0.5;
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
	weight = smoothstep(0, 1, f); // cubic interpolation
	weight = quinticInterpolation(f);

	float x1 = mix(v00, v10, weight.x);
	float x2 = mix(v01, v11, weight.x);
	return mix(x1, x2, weight.y) + 0.5;
}

#endif
