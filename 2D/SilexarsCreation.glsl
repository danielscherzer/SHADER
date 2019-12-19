#version 140

// an alysis of https://www.shadertoy.com/view/XsXXDn
// http://www.pouet.net/prod.php?which=57245
// If you intend to reuse this shader, please add credits to 'Danilo Guanabara'

uniform vec2 u_resolution;
uniform float iTime;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / u_resolution; // range [0,1]^2; origin lower left corner
	vec2 p = uv - 0.5; // range [-0.5 0.5]^2; origin in center
	p.x *= u_resolution.x / u_resolution.y; // view port aspect correction
	vec3 color = vec3(0.0);
	float dist = 0.0;
	float time = iTime;
	for(int channel = 0; channel < 3; channel++)
	{
		time += 0.07; // delay time more with each channel
		dist = length(p); // distance to center
		vec2 uvTime = uv 
			+ p / dist * (sin(time) + 1.0) * abs( sin( 9.0 * dist - 2.0 * time))
;
		color[channel] = 0.01 / length( fract( uvTime) - 0.5);
	}
	fragColor = vec4(color / dist, iTime);
}

out vec4 fragColor;
void main()
{
	mainImage(fragColor, gl_FragCoord.xy);
}
