#version 140

uniform vec2 u_resolution;
uniform float u_time;

float minE(vec2 v)
{
	return min(v.x, v.y);
}

float maxE(vec2 v)
{
	return max(v.x, v.y);
}

float grid(vec2 coord, float thickness)
{
	vec2 distInt = abs(fract(coord + 0.5) - 0.5);
	return smoothstep(0.0, thickness, minE(distInt));
}

float frame(vec2 coord, float thickness)
{
	float dGrid = grid(coord, thickness);
	float grid10 = grid(0.1 * coord, 0.1 * 2.0 * thickness);
	float axis = smoothstep(0.0, 4.0 * thickness, minE(abs(coord)));
	return axis * dGrid * grid10;
}

mat2 rotate(float radiant)
{
	return mat2(cos(radiant), -sin(radiant), sin(radiant), cos(radiant));
}

mat2 interpolate(mat2 a, mat2 b, float weight)
{
	weight = clamp(weight, 0.0, 1.0);
	return (1- weight) * a + weight * b;
}

//draw function line
float plotFunction(vec2 coordIn, vec2 coordOut)
{
	vec2 dist = abs(coordOut - coordIn);
	float f = length(dist);
	
	vec2 gradient = vec2(dFdx(f), dFdy(f));
	float filterWidth = length(gradient) * 2.0;
	return 1 - smoothstep(0, filterWidth, f);
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

	float thickness = maxE((upperRight - lowerLeft) / u_resolution);
	
	float grid_world = frame(coord, thickness);
//	mat2 mtx = rotate(0.5 * 3.1415);
	mat2 mtx = inverse(mat2(1, 2, -3, 4));
	coord = interpolate(mat2(1), mtx, u_time) * coord;
	float grid2 = frame(coord, thickness);

	vec3 color = vec3(grid_world);
	color = mix(color, vec3(0.0, 0.3, 0.0), 1.0 - grid2);

//	fragColor = vec4(grid_world, 1.0);
	fragColor = vec4(color, 1.0);
}

out vec4 color;
void main()
{
	mainImage(color, gl_FragCoord.xy);
}
