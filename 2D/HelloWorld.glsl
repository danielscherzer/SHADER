#version 120

uniform vec2 iResolution;
uniform float iGlobalTime;

void main()
{
	//create uv to be in the range [0..1]x[0..1]
	vec2 uv = gl_FragCoord.xy / iResolution;
	//4 component color red, green, blue, alpha
	vec4 color = vec4(0.7, 0.5, 0.0, 1.0);
//	color.rg = uv * (sin(iGlobalTime) * 0.5 + 1);
//	color.rgb = vec3(0, 0, step(0.5, uv.x)); // step 1 
//	color.rgb = vec3(smoothstep(0.5, 0.55, uv.x)); // step 2 
//	color.rgb = vec3(step(0.5, uv.x) * step(0.5, uv.y)); // step 3 
//	vec2 corner = step(vec2(0.5), uv); // step 4 
//	color.rgb = vec3(corner.x * corner.y); // step 4 
	gl_FragColor = color;
}
