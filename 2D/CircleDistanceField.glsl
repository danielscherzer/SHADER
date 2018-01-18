#version 330

uniform vec2 iResolution;
uniform float iGlobalTime;
	
void main()
{
	//create uv to be in the range [0..1]²
	vec2 uv = gl_FragCoord.xy / iResolution;
	//4 component color red, green, blue, alpha
	vec4 color =  vec4(1);

	//coordinate system scale
	uv -= 0.5;
	uv *= 8.0;
	
	//account for window aspect
	float aspect = iResolution.x / iResolution.y;
	uv.x *= aspect;
	
	//rotate circle centers over time
	float x = sin(iGlobalTime);
	float y = cos(iGlobalTime);
	
	// uv = mod(uv, vec2(2));
	//two circle distance fields
	float distCircle1 = distance(uv, vec2(x, y));
	// distCircle1 = fract(distCircle1 * 5);
	float distCircle2 = distance(uv, vec2(y, x));
	// distCircle2 = fract(distCircle2 * 5);

	color.rgb = vec3(distCircle1); // draw one circular distance field

	float distUnion = min(distCircle1, distCircle2); //todo
	// color.rgb = vec3(distUnion); // draw union

	// float blurryness = 0.031; //control sharpness of circles
	// color.rgb = vec3(smoothstep(0.4, 0.4 + blurryness, distUnion)); 
	
	
	// float distPower = pow(distCircle1, distCircle2);
	// float moveRed = abs(sin(iGlobalTime));
	// color.r = smoothstep(moveRed, blurryness + moveRed, distPower);
	
	// float moveGreen = abs(sin(iGlobalTime + 0.1));
	// color.g = smoothstep(moveGreen, blurryness + moveGreen, distUnion);
	
	// float moveBlue = abs(1 - sin(iGlobalTime + 0.2));
	// color.b = smoothstep(moveBlue, blurryness + moveBlue, 0.5 * distPower);
	
	gl_FragColor = color;
}
