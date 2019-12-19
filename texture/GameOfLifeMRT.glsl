#version 330

uniform vec2 u_resolution;
uniform float iGlobalTime;
uniform vec3 iMouse;
uniform sampler2D texLastFrame0;
uniform sampler2D texLastFrame1;

uniform float iThicknessRadius = 0.03;
uniform float iSoftness = 0.01;

in vec2 uv;

layout(location = 0) out vec4 color;
layout(location = 1) out vec4 isObstacle;


float wasObstacle()
{
	return texture2D(texLastFrame1, uv).a;
}

float drawMouseCircle()
{
	// here pixels of a circle
	float aspect = u_resolution.x / u_resolution.y;
	vec2 pos = uv;
	pos.x *= aspect;
	vec2 pmouse = iMouse.xy / u_resolution;
	pmouse.x *= aspect;
	float circle = 1.0 - smoothstep(iThicknessRadius, iThicknessRadius + iSoftness, distance(pmouse, pos));
	return circle;
}

float calcNewObstacle()
{
	float leftDown = clamp(iMouse.z, 0.0, 1.0);
	float otherUp = 2.0 - iMouse.z;
	return clamp(leftDown * drawMouseCircle() + 0.6 * wasObstacle(), 0, otherUp);
}

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
	//living bacteria keep on living if the have 2 or 3 neighbors
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

vec4 calcNewColor(float seed)
{
	float live = seed + gameStep();
	// draw out
	vec3 color = vec3(0.3, 0.4, 0.6) * live;
	//ghosting
	color += 0.999 * texture2D(texLastFrame0, uv).rgb;
	color -= 1.0 / 1024.0; //dim over time to avoid leftovers
	color = clamp(color, vec3(0), vec3(1));
	return vec4(color, live);
}

void main() 
{
	
	//update obstacles
	isObstacle = vec4(uv, 0, calcNewObstacle());
	
	color = calcNewColor(isObstacle.a);
}
