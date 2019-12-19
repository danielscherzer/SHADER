#version 330

uniform vec2 u_resolution;
uniform float iGlobalTime;

float outsideCircle(vec2 coord, vec2 center, float radius)
{
	float f = distance(coord, center);
	vec2 gradient = vec2(dFdx(f), dFdy(f));
	float filterWidthHalf = length(gradient);
	return smoothstep(radius - filterWidthHalf, radius + filterWidthHalf, f);
//	return step(radius, f);
}

vec2 octantSymmetry(vec2 coord)
{
	float above = step(0.0, coord.y - coord.x); //above y == x line
	vec2 col = vec2(1.0 - above, above);
	mat2 mirror = mat2(col, col.yx); // construct mirror matrix below line => identity otherwise mirror on y == x line
	return mirror * coord;
}

out vec4 color;
void main() {
	// coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy / u_resolution;
	coord.x *= u_resolution.x / u_resolution.y;
	
	// grid
	coord *= 20;
	coord = fract(coord);
	// local coordinates system center origin [-0.5,0.5]
	coord -= 0.5;
	// quadrant symmetry
	coord = abs(coord);
	// line x == y symmetry
	coord = octantSymmetry(coord);

	float noCircle = outsideCircle(coord, vec2(1.0, 0.0), 0.64);
	float noSmallCircle = outsideCircle(coord, vec2(0.5, 0.5), 0.12);

	const vec3 white = vec3(1);
	color = vec4(noCircle * noSmallCircle * white, 1.0);
}
