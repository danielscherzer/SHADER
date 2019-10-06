#version 330
// idea from http://thebookofshaders.com

uniform vec2 iResolution;
uniform float iGlobalTime;
uniform vec3 iMouse;

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

out vec3 color;
void main() {
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/iResolution;
	
	vec2 mouse = iMouse.xy / iResolution;
	
	float value = random(coord.x - mouse.x);
//	value = random(coord.x - iGlobalTime * 0.1); // step 1 
//	value = random(coord.x - mouse.x) + random(random(coord.y) - mouse.y); // step 2 
//	value = random(coord - mouse); // step 3 

//	vec2 lowerLeft = vec2(0.2, 0.2) + 0.01 * vec2(random(coord.y), random(coord.x)); // step 4 
//	value = quad(coord, lowerLeft, vec2(0.5, 0.5)); // step 4 

	const vec3 white = vec3(1);
	color = value * white;
}
