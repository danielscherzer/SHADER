//idea from http://glsl.heroku.com/
uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;
varying vec2 uv;
		
void main()
{
	float scale = 400.0 / 32.0;
	float ring = 20.0;
	float radius = 400.0;
	float gap = 4.0;
	vec2 pos = (uv - 0.5);
	vec2 mouse = iMouse.xy / iResolution;
	float d = length(400.0 * pos);
	// Create the wiggle
	d += 50.0 * mouse.x * (sin(pos.y*scale+iGlobalTime)*sin(pos.x*scale+iGlobalTime*.5));
	// Compute the distance to the closest ring
	float v = mod(d + radius/(ring*2.0), radius/ring);
	v = abs(v - radius/(ring*2.0));
	v = clamp(v-gap, 0.0, 1.0);
	d /= radius;
	vec3 m = fract((d-1.0)*vec3(ring*-.5, -ring, ring*.25)*0.5);
	gl_FragColor = vec4(m*v, 1.0);
}