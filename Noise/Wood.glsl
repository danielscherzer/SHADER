#version 330
//idea from http://thebookofshaders.com/edit.php#09/marching_dots.frag

#include "../libs/Noise.glsl"

uniform vec2 u_resolution;
uniform float iGlobalTime;
uniform vec3 iMouse;

const float PI = 3.1415926535897932384626433832795;
const float TWOPI = 2 * PI;
const float EPSILON = 10e-4;

vec2 rotate2D(vec2 coord, float angle)
{
	mat2 rot =  mat2(cos(angle),-sin(angle), sin(angle),cos(angle));
	return rot * coord;
}

float lines(vec2 pos, float b){
	float f = abs((sin(pos.x * PI) + b * 2.0)) * .5;
	return smoothstep(0.0, .5 + b * .5, f);
}

vec3 wood(vec2 coord)
{
	coord = rotate2D(coord, gnoise(coord)); // step 1 rotate the space
	float weight = lines(coord * 10.0, 0.5); // draw lines
	return 	mix(vec3(0.4, 0.2, 0), vec3(0.8, 0.8, 0), weight);
}

out vec3 color;
void main() {
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/u_resolution;

	color = wood(0.5 + coord.yx * vec2(10.,5.));
}
