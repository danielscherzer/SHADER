#version 140

uniform vec2 u_resolution;
uniform float iGlobalTime;

float min(vec2 v)
{
	return min(v.x, v.y);
}

float max(vec2 v)
{
	return max(v.x, v.y);
}

float grid(vec2 coord, float thickness)
{
	vec2 distInt = abs(fract(coord + 0.5) - 0.5);
	return smoothstep(0.0, thickness, min(distInt));
}

float frame(vec2 coord, float thickness)
{
	float grid = grid(coord, thickness);
	float grid10 = grid(0.1 * coord, 0.1 * 2.0 * thickness);
	float axis = smoothstep(0.0, 4.0 * thickness, min(abs(coord)));
	return axis * grid * grid10;
}

mat2 rotate(float radiant)
{
	return mat2(cos(radiant), -sin(radiant), sin(radiant), cos(radiant));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	//map coordinates in range [0,1]
	vec2 coord01 = gl_FragCoord.xy/u_resolution;
	//screen aspect
	vec2 aspectScale = vec2(u_resolution.x / u_resolution.y, 1.0);
	//coordinate system corners
	float delta = 7;
	vec2 lowerLeft = vec2(-delta, -delta) * aspectScale;
	vec2 upperRight = vec2(delta, delta) * aspectScale;
	//setup coordinate system
	// maps normalized [0..1] coordinates 
	// into range [lowerLeft, upperRight]
	vec2 coord = mix(lowerLeft, upperRight, coord01);

	float thickness = max((upperRight - lowerLeft) / u_resolution);
	float grid_world = frame(coord, thickness);
	coord += 0.2;
	coord = rotate(1.8) * coord;
	float grid2 = frame(coord, thickness);

	vec3 color = vec3(grid_world);
//	color = vec3(grid2);
	color = mix(color, vec3(0.0, 0.3, 0.0), 1.0 - grid2);

//	fragColor = vec4(grid_world, 1.0);
	fragColor = vec4(color, 1.0);
}

out vec4 color;
void main()
{
	mainImage(color, gl_FragCoord.xy);
}
