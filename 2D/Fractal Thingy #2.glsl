uniform vec2 u_resolution;
uniform float u_time;

//from https://www.shadertoy.com/view/Xd2Bzw

void main()
{
	// set position
	vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) * 0.4 / u_resolution.y;

	// breathing effect
	p += p * sin( dot(p, p) * 20.0 - u_time) * .04;

	vec4 c = vec4(0);
	vec4 shearConstant = 0.78 * vec4(1.0, 7.0, 3.0, 1.0);
	// accumulate color
	for (float i = 0.5 ; i < 8.0; i++)
	{
		mat2 shear = mat2( cos(0.01 * u_time * i * i + shearConstant)); // https://en.wikipedia.org/wiki/Shear_matrix
		p = abs(2.0 * fract(p - 0.5) - 1.0) * shear;

		// coloration
		c += exp( -5.0 * abs(p.y) ) * ( cos( vec4(2.0, 3.0, 1.0, 0.0) * i) * 0.5 + 0.5);
	}
	// palette
	c.gb *= 0.5;
	gl_FragColor = c;
}
