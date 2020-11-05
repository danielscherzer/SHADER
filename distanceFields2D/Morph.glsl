// idea from https://thebookofshaders.com/edit.php?log=160414040957
uniform vec2 u_resolution;
uniform float u_time;

float circle(vec2 p, float radius) {
	return length(p) - radius;
}

//http://thndl.com/square-shaped-shaders.html
float polygon(vec2 p, int vertices, float size) {
	float a = atan(p.x, p.y) + 0.2;
	float b = 6.28319 / float(vertices);
	return cos(floor(0.5 + a / b) * b - a) * length(p) - size;
}

float opOnion( in vec2 p, in float r )
{
  return abs(polygon(p, 3, 0.2)) - r;
}

void main() {
	vec2 st = gl_FragCoord.xy / u_resolution.xy;
	st -= 0.5; // put origin into center

	float shape0 = circle(st, 0.4);
	float shape1 = polygon(st, 3, 0.2);
	float shape2 = opOnion(st, 0.05);

	float morphWeight = 0.5 + 0.5 * sin(u_time * 0.5 - 3.14158 / 2.0); // animate morph over time
	float dist = mix(shape0, shape2, morphWeight); // morph between two shapes
	float stepFunction = smoothstep(0.0, 1.0 / u_resolution.x, dist);

	vec3 color = vec3(stepFunction);
	gl_FragColor = vec4(color, 1.0);
}
