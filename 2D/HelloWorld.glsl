#version 140

uniform vec2 u_resolution;
uniform float iGlobalTime;

void main()
{
	//create uv to be in the range [0..1]x[0..1]
	vec2 uv = gl_FragCoord.xy / u_resolution;
	//4 component color red, green, blue, alpha
	vec4 color = vec4(0.6, 0.2, 0.7, 1.0);
	float red = floor(uv.y * 10.0) / 10.0; // step 1
	vec4 colorA = vec4(red, 1.0 - red, 0.0, 1.0); // step 1
	vec4 colorB = vec4(red, red, 1.0, 1.0); // step 1
	color = mix(colorA, colorB, uv.x); // step 1
//	color.rg = uv * (sin(iGlobalTime) * 0.5 + 1);
//	color.rgb = vec3(0, 0, step(0.5, uv.x)); // step 2 
//	color.rgb = vec3(smoothstep(0.5, 0.55, uv.x)); // step 3
//	color.rgb = vec3(step(0.5, uv.x) * step(0.5, uv.y)); // step 4
//	vec2 corner = step(vec2(0.5), uv); // step 5 
//	color.rgb = vec3(corner.x * corner.y); // step 5 
	gl_FragColor = color;
}
