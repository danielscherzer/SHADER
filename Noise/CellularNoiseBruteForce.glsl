#version 330
//idea from http://thebookofshaders.com

const int COUNT = 100;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

uniform vec2 u_resolution;
uniform float iGlobalTime;
uniform vec3 iMouse;

float time = iGlobalTime * 0.1;
vec2 res = u_resolution;

void main() {
	//coordinates in range [0,1]
    vec2 coord = gl_FragCoord.xy/res;
	
	float minDist = 1e4;

	//we calculate the minimal distance to COUNT random points
	for(int i = 0; i < COUNT; ++i)
	{
		vec2 point = random2(vec2(i, i));
		
		point = 0.5 + 0.5 * sin(time + (time + 10) * point); // animate each point
		
		minDist = min(distance(coord, point), minDist);
	}
		
	vec3 color = vec3(minDist) * 5;
		
    gl_FragColor = vec4(color, 1.0);
}
