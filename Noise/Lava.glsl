#version 120
// idea from http://thebookofshaders.com/edit.php#09/marching_dots.frag

#include "../libs/Noise.glsl"

uniform vec2 iResolution;
uniform float iGlobalTime;
uniform vec3 iMouse;

const float PI = 3.1415926535897932384626433832795;

vec3 lavaLamp(vec2 coord, float time)
{
	float trnNoise = gnoise(coord + vec2(time * 0.1)); // noise that is translated over time

	vec2 rotCoord = coord * vec2(cos(time * 0.15), sin(time * 0.091)); //rotate coordinate over time
	float rotNoise = gnoise(rotCoord * 0.1) * PI; //rotating noise, low frequency
	
	//trnNoise += gnoise(coord + vec2(cos(rotNoise), sin(rotNoise))); // step 1 add noise that is translated by rotating noise

	//trnNoise = smoothstep(0.8, 1, trnNoise); // step 2 sharper borders
	return mix(vec3(0, 0, 1), vec3(1, 0, 0), 1 - trnNoise);
}

void main() {
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/iResolution;
		
	vec3 color = lavaLamp(coord * 5, iGlobalTime * 3);
		
	gl_FragColor = vec4(color, 1.0);
}
