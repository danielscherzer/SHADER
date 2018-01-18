#version 330

#include "../libs/noise3d.glsl"

uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;
uniform sampler2D texLastFrame0;

in vec2 uv;

float Frost(vec4 data)
{
	return data.b;
}

vec4 Save(float lava, float frost)
{
	return vec4(lava, 0, frost, 0);
}

float SeedLava(vec2 coord)
{
	return smoothstep(0.2, 1, snoise(vec3(coord * 5, 0.1 * iGlobalTime)));
}

float NeighborFrost(vec2 uv) 
{
	vec2 uvUnit = 1.0 / iResolution.xy;
	float frost = 0;
	for (int y = -1; y <= 1; ++y)
	{
		for (int x = -1; x <= 1; ++x) 
		{
			vec2 delta = uvUnit * vec2(float(x), float(y));
			frost += Frost(texture(texLastFrame0, uv + delta));
		}
	}
	return frost;
}

float SeedFrost(vec2 coord)
{
	float frost = NeighborFrost(coord);
	if(1 == int(iMouse.z))
	{
		//player adds small circle of destruction
		vec2 mouse = iMouse.xy / iResolution;
		frost += distance(coord, mouse) < 0.01 ? 1 : 0;
	}
	return min(1, frost);
}

void main() 
{
	float lava = SeedLava(uv);
	float frost = SeedFrost(uv);
	frost *= lava; //limit frost to move along lava structures
	lava *= 1 - frost; //freeze lava structures
	//coloring
	vec4 color = Save(lava, frost);
	if(3 == int(iMouse.z)) color = vec4(0); //clear on right button
	gl_FragColor = vec4(clamp(color, vec4(0), vec4(1)));
}
