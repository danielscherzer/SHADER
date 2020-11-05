#version 330

#include "../libs/operators.glsl"

uniform vec2 u_resolution;
uniform float u_time;
float time = u_time * 0.1;
	
vec2 random2( vec2 p ) {
	return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float distField(vec2 coord)
{
	//cellular noise
	const int COUNT = 100;
	float minDist = 1e6;
	
	//we calculate the minimal distance to COUNT random points
	for(int i = 0; i < COUNT; ++i)
	{
		vec2 point = random2(vec2(i, i));
		
		point = 0.5 + 0.5 * sin(time + (time + 10) * point); // animate each point
		
		minDist = smin(distance(coord, point) * 40, minDist, 1.0);
//		minDist = min(distance(coord, point) * 40, minDist);
	}
	return minDist;
}

//distance to nearest integer
float distToInt(float coord)
{
	float dist = fract(coord);
	return dist > 0.5 ? 1.0 - dist : dist;
}

//coordinates in range [0,1]
vec3 mainImage(vec2 coord)
{
	float dist = distField(coord);
	float levelSet = distToInt(dist);

	float filterRadius = fwidth(levelSet); //control sharpness of circles
	float thickness = 0.05;
	
	float contour = smoothstep(thickness - filterRadius, thickness + filterRadius, levelSet); // repeat step
	// contour = dist;
	
	return vec3(contour);
}

out vec4 fragColor;
void main() {
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/u_resolution;
	fragColor = vec4(mainImage(coord), 1.0);
}