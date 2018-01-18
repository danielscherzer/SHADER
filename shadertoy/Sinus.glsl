uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;
varying vec2 uv;
		
void main()
{
	// float Frequency = 100.0;
	// float Phase = iGlobalTime * 2.0;
	// float Amplitude = 0.01;
	// uv.y += sin(uv.x * Frequency  + Phase) * Amplitude;

	vec2 p = uv - 0.5;
	vec2 m = iMouse.xy / iResolution;
	float sx = 0.5 * (p.x + 0.5) * m.y * sin(20.0 * p.x * (m.x * 2.0) - 10.0 * iGlobalTime);
	float dy = 1.0 / (500.0 * abs(p.y - sx));
	gl_FragColor = vec4(0.01, 0.8 * dy, 10.0 * dy, 1.0 );
}
