// http://www.pouet.net/prod.php?which=57245
// If you intend to reuse this shader, please add credits to 'Danilo Guanabara'
// an alysis of https://www.shadertoy.com/view/XsXXDn by 'Daniel Scherzer'

uniform vec2 u_resolution;
uniform float u_time;

void main()
{
	vec2 uv = gl_FragCoord.xy / u_resolution; // range [0,1]^2; origin lower left corner
	vec2 p = uv - 0.5; // range [-0.5 0.5]^2; origin in center
	p.x *= u_resolution.x / u_resolution.y; // view port aspect correction
	float dist = length(p); // distance to center
	vec2 p_hat = p / dist; // normalized coordinates
	vec3 color = vec3(0.0);
	float time = u_time;
	//iterate over the color channels
	for(int channel = 0; channel < 3; channel++)
	{
		time += 0.07; // delay time more and more with each channel
		// create expanding circle; left half fades to black; right half to white; result in x and y is the same, but rotated 90
		vec2 expandingCircle = uv + p_hat * (sin(time) + 1.0) * abs( sin( 9.0 * dist - 2.0 * time));
		// chop up the circles with fract creating repreated color bands; result in x and y is the same, but rotated 90
		vec2 colorBands = fract(expandingCircle);
		// combine x and y channel, creating an [interference pattern](https://en.wikipedia.org/wiki/Wave_interference)
		float interference = length(colorBands - 0.5);
		// invert function and scale it down
		color[channel] = 0.01 / interference;
	}
	// "normalize"
	gl_FragColor = vec4(color / dist, 1.0);
}
