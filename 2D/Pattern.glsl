#version 330

uniform vec2 iResolution;
uniform float iGlobalTime;

const float PI = 3.14159265359;
const float TWOPI = 2 * PI;
const float EPSILON = 10e-4;

float smoothBox(vec2 coord, vec2 size, float smoothness){
    size = vec2(0.5) - size * 0.5;
    vec2 uv = smoothstep(size, size + vec2(smoothness), coord);
    uv *= smoothstep(size, size + vec2(smoothness), vec2(1.0) - coord);
    return uv.x*uv.y;
}

vec2 rotate2D(vec2 coord, float angle)
{
    mat2 rot =  mat2(cos(angle),-sin(angle), sin(angle),cos(angle));
    return rot * coord;
}

float rectFunc(float x, float from, float to)
{
	return step(from, x) - step(to, x);
}

float grid(in vec2 coord)
{
	coord *= 10;
	float unevenRow = step(1, mod(coord.y, 2));
    coord.x += unevenRow * 0.5;
	
	float row7 = rectFunc(coord.y, 6, 7);
	float col4 = rectFunc(coord.x, 3, 4);
	float element47 = row7 * col4;
	
	coord = fract(coord);
	coord -= 0.5;
	coord = rotate2D(coord, element47 * iGlobalTime);
	coord += 0.5;
	return smoothBox(coord, vec2(0.9, 0.9), 0.05);
}

void main() {
	//coordinates in range [0,1]
    vec2 coord = gl_FragCoord.xy/iResolution;
	
	coord.x *= iResolution.x / iResolution.y;
	
	float grid = grid(coord);
	const vec3 white = vec3(1);

	vec3 color = grid * white;
		
    gl_FragColor = vec4(color, 1.0);
}
