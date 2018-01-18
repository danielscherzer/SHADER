///idea from http://thebookofshaders.com/edit.php#09/marching_dots.frag
#version 330

uniform vec2 iResolution;
uniform float iGlobalTime;

const float PI = 3.1415926535897932384626433832795;
const float TWOPI = 2 * PI;
const float EPSILON = 10e-4;

float circle(vec2 coord, float radius)
{
    vec2 pos = vec2(0.5) - coord;
    return smoothstep(1 - radius, 1 - radius + radius * 0.2 , 1 - dot(pos, pos) * PI);
}

float repeatStep(float x, float width)
{
	return step(0.5 * width, mod(x, width));
}

float move(float time)
{
	float timeStepped = time * repeatStep(time, 2);
	return timeStepped;
}

float direction(float x)
{
	float uneven = step(1, mod(x, 2));
    return sign(uneven - 0.5);
}

void main() {
	//coordinates in range [0,1]
    vec2 coord = gl_FragCoord.xy/iResolution;
	
	coord.x *= iResolution.x / iResolution.y; //aspect
	
	coord *= 10;
    coord.x += direction(coord.y) * move(iGlobalTime);
    coord.y += direction(coord.x) * move(iGlobalTime - 1);

	coord = fract(coord);
	
	float grid = 1 - circle(coord, 0.3);
	const vec3 white = vec3(1);

	vec3 color = grid * white;
		
    gl_FragColor = vec4(color, 1.0);
}
