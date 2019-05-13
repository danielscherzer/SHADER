#version 330
// motivation : https://www.shadertoy.com/view/XsXXDn
// idea from https://thebookofshaders.com/05/ nice explanation + links to function tools
// look at http://www.cdglabs.org/Shadershop/ for visual function composing

#include "../libs/Noise.glsl"
#include "../libs/operators.glsl"

uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;
varying vec2 uv;

const float PI = 3.14159265359;
const float TWOPI = 2 * PI;
const float EPSILON = 10e-4;

// maps normalized [0..1] coordinates 
// into range [lowerLeft, upperRight]
vec2 map(vec2 coord01, vec2 lowerLeft, vec2 upperRight)
{
	vec2 extents = upperRight - lowerLeft;
	return lowerLeft + coord01 * extents;
}

//calculate the smallest just visible width/height for objects
vec2 screenDelta(vec2 resolution, vec2 lowerLeft, vec2 upperRight)
{
	return (upperRight - lowerLeft) / resolution;
}

//distance to nearest integer
float distToInt(float coord)
{
	float dist = fract(coord);
	return dist > 0.5 ? 1 - dist : dist;
}

vec2 distToInt(vec2 coord)
{
	vec2 dist = fract(coord);
	dist.x = dist.x > 0.5 ? 1 - dist.x : dist.x;
	dist.y = dist.y > 0.5 ? 1 - dist.y : dist.y;
	return dist;
}

float grid(vec2 coord, vec2 screenDelta)
{
	vec2 dist = vec2(distToInt(coord));
	vec2 smoothGrid = smoothstep(vec2(0), screenDelta, dist);
	return min(smoothGrid.x, smoothGrid.y);
}

float onAxis(vec2 coord, vec2 screenDelta)
{
	vec2 absCoord = abs(coord);
	vec2 distAxis = smoothstep(vec2(0), screenDelta, absCoord);
	return min(distAxis.x, distAxis.y);
}

float function(float x)
{
	float y = x;
//	y = abs(x); // step 1 returns the absolute value of x
//	y = min(0.0, x); // step 2 return the lesser of x and 0.0
//	y = max(0.0, x); // step 3 return the greater of x and 0.0
//	y = step(2, x); // step 4 
//	y = smoothstep(-1, 1, x); // step 5 
//	y = fract(x); // step 6 return only the fraction part of a number
//	y = mod(x, 2); // step 7 
//	y = clamp(x, 0.0, 1.0); // step 8 constrain x to lie between 0.0 and 1.0
//	y = ceil(x); // step 9 nearest integer that is greater than or equal to x
//	y = floor(x); // step 10 nearest integer less than or equal to x
//	y = sign(x); // step 11 extract the sign of x
	vec2 mouse = iMouse.xy / iResolution;
	y = 5 * mouse.y * sin(x * mouse.x * 5); // step 12 
//	y = trunc(x); // step 13 
	// y = abs(sin(x)); // step 14 
	// y = fract(sin(x) * 1234567.0); // step 15 
//	y = ceil(sin(x)) + floor(sin(x)); // step 16 
	// y = sign(sin(x)) * pow(sin(x), 9.0); // step 17 
	// y = exp(-0.4 * abs(x)) * 1 * cos(2 * x); // step 18 
//	y = mod(x + 1, 2.0) - 1; // step 19 
//	y = abs(mod(x + 1, 2.0) - 1); // step 20 repeated tent
//	y = step(2, mod(x, 4.0)); // step 21 repeat step
//	y = smoothstep(-0.5, 1, cos(x)) * 2; // step 22 
	float fact = 1;
//	y = floor(x / fact); // step 23 
//	y = floor(0.5 + x / fact) * fact; // step 24 
//	y = x - floor(0.5 + x / fact) * fact; // step 25 
//	y = cos(x - floor(0.5 + x / fact) * fact); // step 26 
	// y = distToInt(x); // step 27 
	// y = step(1, x) - step(2, x); // step 28 
//	y = step(1, mod(x, 2)); // step 29 
	// y = opRepeat(vec3(x), vec3(2)).x; // step 30 
//	y = sin(x) + 0.1 * sin(16*x + mouse.x * 100); // step 31 
	// y = rand(x); // step 32
	// y = rand(ceil(x + 0.5)) * 5; // step 33
	// y = noise(x - mouse.x * 30); // step 34
	// y = gnoise(x - mouse.x * 30); // step 34
	// y = noise(x + mouse.x * 100) + 0.1 * noise(16*x); // step 35 
	return y;
}

//draw function line
float plotFunction(vec2 coord, vec2 screenDelta)
{
	float f = function(coord.x) - coord.y;
	float dist = abs(f);
	
	vec2 gradient = vec2(dFdx(f), dFdy(f));
	float filterWidth = length(gradient) * 2.0;
	return 1 - smoothstep(0, filterWidth, dist);

	// return 1 - step(0.1, dist);
	// return 1 - smoothstep(0, screenDelta.y, dist);
}

float distPointLine(vec2 point, vec2 a, vec2 b)
{
	vec2 ab = b - a;
	float numerator = abs(ab.y * point.x - ab.x * point.y + b.x * a.y - b.y * a.x);
	float denominator = length(ab);
	return numerator / denominator;
}

float plotDifferentiableFunction(vec2 coord, vec2 screenDelta)
{
	//use central difference to make a line approximation
	float ax = coord.x - EPSILON;
	float bx = coord.x + EPSILON;
	vec2 a = vec2(ax, function(ax));
	vec2 b = vec2(bx, function(bx));
	float dist = distPointLine(coord, a, b);
	return 1 - smoothstep(0, screenDelta.y, dist);
}

void main() {
	//map coordinates in range [0,1]
	vec2 coord01 = gl_FragCoord.xy/iResolution;
	//screen aspect
	float aspect = 1;//iResolution.x / iResolution.y;
	//coordinate system corners
	float delta = 8;
	vec2 lowerLeft = vec2(-delta * aspect, -delta);
	vec2 upperRight = vec2(delta * aspect, delta);
	//setup coordinate system
	vec2 coord = map(coord01, lowerLeft, upperRight);
	//calculate just visible screen deltas
	vec2 screenDelta = screenDelta(iResolution, lowerLeft, upperRight);

	//axis
	vec3 color = vec3(onAxis(coord, 2 * screenDelta));
	//grid
	vec3 gridColor = vec3(1 - (1 - grid(coord, screenDelta)) * 0.1);
	//combine
	color *= gridColor;
	
	//function
	// float graph = plotDifferentiableFunction(coord, 4 * screenDelta);
	float graph = plotFunction(coord, 4 * screenDelta);

	// combine
	const vec3 green = vec3(0.0, 1.0, 0.0);
	color = mix(color, green, graph);

	gl_FragColor = vec4(color, 1.0);
}
