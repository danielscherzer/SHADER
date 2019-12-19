#version 330

uniform vec2 u_resolution;
uniform float iGlobalTime;

const float PI = 3.1415926535897932384626433832795;
const float TWOPI = 2 * PI;

float triangle(vec2 coord, float smoothness)
{
	return smoothstep(1 - smoothness, 1 + smoothness, coord.x + coord.y);
}

float diagonal(vec2 coord, float smoothness)
{
	return smoothstep(coord.x - smoothness, coord.x, coord.y) - smoothstep(coord.x, coord.x + smoothness, coord.y);
}

float circles(vec2 coord)
{
	float a = 0.4;
	float b = 0.6;
	float len = length(coord);
	float len1 = length(coord - vec2(1));
	return (step(len, b) - step(len, a) ) + (step(len1, b) - step(len1, a) );
}

vec2 rotate2D(vec2 coord, float angle)
{
	mat2 rot =  mat2(cos(angle),-sin(angle), sin(angle),cos(angle));
	return rot * coord;
}

//map coordinates to angles 0°,90°,180°, 270°
float angle(vec2 coord)
{
	float index = trunc(mod(coord.x, 5)) * 3;
	index += trunc(mod(coord.y, 3)) * 7;
	return trunc(mod(index, 4)) * 0.5 * PI;
}

vec2 repeatAndRotate(vec2 coord, float scale, float timeScale)
{
	coord *= scale; //zoom
	float angle = angle(coord);

	// angle = 0;
	coord = fract(coord);
	coord -= 0.5;
//	coord = rotate2D(coord, angle + TWOPI * timeScale * iGlobalTime); // step 2 rotate
	coord += 0.5;
	
	return coord;
}

out vec4 outColor;

void main() 
{
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/u_resolution;
	
	coord.x *= u_resolution.x / u_resolution.y; //aspect
	
//	coord = repeatAndRotate(coord, 3, 0.21); // step 1 repeat
//	coord = repeatAndRotate(coord, 4, 0.1); // step 3 recursive pattern
//	coord = repeatAndRotate(coord, 4, 0.1); // step 4 recursive pattern

	float grid = triangle(coord, 0.01);
//	grid = diagonal(coord, 0.05); // step 5 
//	grid = circles(coord); // step 6 

	const vec3 white = vec3(1);
	vec3 color = (1 - grid) * white;

	outColor = vec4(color, 1);
}

