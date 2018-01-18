#version 330

#include "../libs/noise3d.glsl"
#include "../libs/operators.glsl"

uniform vec2 iResolution;
uniform float iGlobalTime;
float time = iGlobalTime * 0.1;
	
float rand(float seed)
{
	return fract(sin(seed) * 1231534.9);
}

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float distCircles(vec2 uv)
{
	//coordinate system scale
	uv -= 0.5;
	uv *= 8.0;
	
	//account for window aspect
	float aspect = iResolution.x / iResolution.y;
	uv.x *= aspect;
	
	//rotate circle centers over time
	float x = sin(iGlobalTime);
	float y = cos(iGlobalTime);
	
	//two circle distance fields
	float distCircle1 = distance(uv, vec2(x, y));
	float distCircle2 = distance(uv, vec2(y, x));

	return min(distCircle1, distCircle2); //todo
}

float SeedLava(vec2 coord)
{
	float noise = snoise(vec3(coord * 5, 0.1 * iGlobalTime));
	return abs(noise);
	return smoothstep(0.2, 1, noise);
}

float himmelblau(vec2 coord)
{
	float x = coord.x;
	float y = coord.y;
    return pow( x * x + y - sin(time) * 11, 2 ) + pow( x + y * y - cos(time) * 7, 2 );
}

float distField(vec2 coord)
{
	// return distCircles(coord);
	// return SeedLava(coord);
	// return himmelblau(coord * 5- 3 );
	//cellular noise
	const int COUNT = 100;
	float minDist = 1e6;
	
	//we calculate the minimal distance to COUNT random points
	for(int i = 0; i < COUNT; ++i)
	{
		vec2 point = random2(vec2(i, i));
		
		point = 0.5 + 0.5 * sin(time + (time + 10) * point); // animate each point
		
		minDist = smin(distance(coord, point) * 40, minDist, 01.1);
	}
	return minDist;
}

void main()
{
	//create uv to be in the range [0..1]²
	vec2 uv = gl_FragCoord.xy / iResolution;

	float dist = distField(uv);

	float blurryness = 0.012; //control sharpness of circles
	float thickness = 0.005;
	
	float contour = smoothstep(thickness, thickness + blurryness, distToInt(dist)); // repeat step
	// contour = dist;
	
	gl_FragColor = vec4(vec3(contour), 1);
}
