#version 140
// idea from http://thebookofshaders.com/edit.php#09/marching_dots.frag

uniform vec2 iResolution;
uniform float iGlobalTime;

float circle(vec2 coord, float radius)
{
	float dist = distance(vec2(0.5), coord);
	float filterRadius = fwidth(dist);
	return smoothstep(radius - filterRadius, radius + filterRadius, dist);
	return step(radius, dist);
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

//coordinates in range [0,1] return color
vec3 mainImage(vec2 coord) {
	coord *= 10;
	coord.x += direction(coord.y) * move(iGlobalTime);
	coord.y += direction(coord.x) * move(iGlobalTime - 1);

	coord = fract(coord);
	
	const vec3 white = vec3(1);
	return circle(coord, 0.3) * white;
}

void main() {
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/iResolution;
	coord.x *= iResolution.x / iResolution.y; //aspect
	gl_FragColor = vec4(mainImage(coord), 1.0);
}