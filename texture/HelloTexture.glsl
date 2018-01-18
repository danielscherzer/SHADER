#version 330

uniform vec2 iResolution;
uniform float iGlobalTime;
uniform sampler2D tex;

void main()
{
	vec2 uv = gl_FragCoord.xy / iResolution;
	
	//some wobbeling
	// float Frequency = 100.0;
	// float Phase = iGlobalTime * 2.0;
	// float Amplitude = 0.01;
	// uv.y += sin(uv.x * Frequency  + Phase) * Amplitude;
	
	//lookup color in texture at position uv
	vec3 color = texture(tex, uv).rgb;
	gl_FragColor = vec4(color, 1.0);
}
