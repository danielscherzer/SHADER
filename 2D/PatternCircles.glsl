uniform vec2 u_resolution;
uniform float u_time;
// idea from http://thebookofshaders.com/edit.php#09/marching_dots.frag

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
	float timeStepped = time * repeatStep(time, 2.0);
	return timeStepped;
}

float direction(float x)
{
	float uneven = step(1.0, mod(x, 2.0));
	return sign(uneven - 0.5);
}

//coordinates in range [0,1] return color
vec3 mainImage(vec2 coord) {
	coord *= 10.0;
	coord.x += direction(coord.y) * move(u_time);
	coord.y += direction(coord.x) * move(u_time - 1.0);

	coord = fract(coord);
	
	const vec3 white = vec3(1);
	return circle(coord, 0.3) * white;
}

void main() {
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy / u_resolution;
	coord.x *= u_resolution.x / u_resolution.y; //aspect
	gl_FragColor = vec4(mainImage(coord), 1.0);
}