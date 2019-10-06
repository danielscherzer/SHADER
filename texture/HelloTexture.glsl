#version 330

uniform vec2 iResolution;
uniform float iGlobalTime;
uniform sampler2D tex0;
uniform sampler2D tex1;

void main()
{
	vec2 uv = gl_FragCoord.xy / iResolution;
	
	//some wobbeling
	// float Frequency = 100.0;
	// float Phase = iGlobalTime * 2.0;
	// float Amplitude = 0.01;
	// uv.y += sin(uv.x * Frequency  + Phase) * Amplitude;
	
	//lookup color in texture at position uv
	vec3 color1 = texture(tex0, uv).rgb;
	vec3 color2 = texture(tex1, uv).rgb;
	vec3 color = mix(color1, color2, 0.5);
	gl_FragColor = vec4(color, 1.0);
}
