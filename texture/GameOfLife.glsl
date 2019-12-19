#version 330

uniform vec3 iMouse;
uniform float iSeedRadius = 0.07;
uniform vec2 u_resolution;
uniform float iGlobalTime;
uniform sampler2D texLastFrame0;

in vec2 uv;

int countNeighbors(vec2 uv, bool isLive) 
{
	vec2 uvUnit = 1.0 / u_resolution.xy;
	int count = 0;
	#define KERNEL_R 1
	for (int y = -KERNEL_R; y <= KERNEL_R; ++y)
	{
		for (int x = -KERNEL_R; x <= KERNEL_R; ++x) 
		{
			vec2 delta = uvUnit * vec2(float(x), float(y));
			if (0.0 < texture2D(texLastFrame0, uv + delta).a )
				++count;
		}
	}
	if (isLive)
		--count;
	return count;
}

float gameStep() {
	bool isLive = texture2D(texLastFrame0, uv).a > 0.0;
	int neighbors = countNeighbors(uv, isLive);
	
	//apply game rules:
	//living bacteria keep on lifing if the have 2 or 3 neighbors
	//new bacteria start to life if they have exactly 3 neighbors
	if (isLive)
	{
		return ( (2 == neighbors) || (3 == neighbors)) ? 1.0 : 0.0;
	}
	else 
	{
		return (3 == neighbors) ? 1.0 : 0.0;
	}
}

float seedValue()
{
	// here pixels of a circle
	float aspect = u_resolution.x / u_resolution.y;
	vec2 pos = uv;
	pos.x *= aspect;
	vec2 pmouse = iMouse.xy / u_resolution;
	pmouse.x *= aspect;
	return distance(pmouse, pos) < iSeedRadius ? 1.0 : 0.0;
}

void main() 
{
	float live = seedValue()  + gameStep();
	// draw out
	vec3 color = vec3(0.3, 0.4, 0.6) * live;
	//ghosting
	color += 0.99 * texture2D(texLastFrame0, uv).rgb;
	color -= 1.0 / 256.0; //dim ove r time to avoid leftovers
	color = clamp(color, vec3(0), vec3(1));
	gl_FragColor = vec4(color, live);
}
