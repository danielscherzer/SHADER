#version 330

// based on http://www.iquilezles.org/www/articles/distance/distance.htm
const float PI = 3.14159265359;
const float TWOPI = 2 * PI;
const float EPSILON = 10e-4;

uniform vec2 iResolution;
uniform float iGlobalTime;
uniform vec3 iMouse;
	
float distToInt(float coord)
{
	float dist = fract(coord);
	return dist > 0.5 ? 1.0 - dist : dist;
}

float distField(const vec2 coord)
{
//	return distance(vec2(0.5), coord);
	//cartesian to polar coordinates
	float r = length(coord); // radius of current pixel
	float a = atan(coord.y, coord.x) + PI; //angel of current pixel [0..2*PI] 
	
	return r - 1 + 0.5 * sin(3 * a + 2 * r * r);
}

vec2 grad(const vec2 coord, const float pixelDelta)
{
	vec2 h = vec2( pixelDelta, 0.0 );
	return vec2( distField(coord + h.xy) - distField(coord - h.xy),
				distField(coord + h.yx) - distField(coord - h.yx) )/(2.0 * h.x);
}

vec2 gradGPU(const vec2 coord, const float pixelDelta)
{
	float f = distField(coord);
	return vec2( dFdx(f), dFdy(f) ) / pixelDelta;
}

void main()
{
	//create uv to be in the range [0..1]²
	vec2 uv = gl_FragCoord.xy / iResolution;
	
	float threshold = abs(sin(iGlobalTime));

	// range [-1..1]²
	uv = vec2(1) - 2 * uv;
	//aspect correction
	uv.x *= iResolution.x / iResolution.y;
	uv *= 2; // range [-2..2]²
	float pixelDelta = 4.0 / iResolution.y; //range / res
	
	float f = distField(uv);
	vec2 g = //uv.x < 0 ? gradGPU(uv, pixelDelta) : 
	grad(uv, pixelDelta);
	float de = abs(f) / length(g);

	float subSet = f;
	// subSet = step(threshold, f);
	// subSet = smoothstep(threshold + 0.0, threshold + 0.025, abs(f));
	// subSet = de;
	// subSet = clamp(de, 0.0, 0.025) * 20;
	// subSet = smoothstep(0.0, 0.025, de);

	float thickness = 0.05;
	float d = distToInt(de * 5);
	float blurryness = 0.012; //control sharpness
	// subSet = smoothstep(thickness, thickness + blurryness, d); // repeat step	
	
	vec3 color = vec3(subSet);	
	
	gl_FragColor = vec4(color, 1.0);
}

