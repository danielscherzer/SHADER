///idea from http://thebookofshaders.com
#version 330

uniform vec2 iResolution;
uniform float iGlobalTime;

const float PI = 3.1415926535897932384626433832795;
const float TWOPI = 2 * PI;
const float EPSILON = 10e-4;

float quad(vec2 coord, vec2 lowerLeft, vec2 size)
{
	vec2 a = step(lowerLeft, coord);
	vec2 b = 1 - step(lowerLeft + size, coord);
	return a.x * b.x * a.y * b.y;
}

float random(float seed)
{
	return fract(sin(seed) * 1231534.9);
}

float random(vec2 coord) { 
    return random(dot(coord, vec2(21.97898, 7809.33123)));
}

void main() {
	//coordinates in range [0,1]
    vec2 coord = gl_FragCoord.xy/iResolution;
	
	float value = random(coord.x);
	value = random(coord);

	// vec2 lowerLeft = vec2(0.2, 0.2) + 0.01 * vec2(random(coord.y), random(coord.x));
	// value = quad(coord, lowerLeft, vec2(0.5, 0.5));

	const vec3 white = vec3(1);
	vec3 color = value * white;
		
    gl_FragColor = vec4(color, 1.0);
}
