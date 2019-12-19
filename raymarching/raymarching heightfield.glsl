#version 330

#include "../libs/camera.glsl"
#include "../libs/rayIntersections.glsl"

uniform float iGlobalTime;
uniform vec2 u_resolution;
uniform sampler2D tex0;
uniform sampler2D tex1;

const float epsilon = 0.0001;
const float BIGNUMBER = 10e6;
const vec3 terrainBottomCenter = vec3(0, -3, 0);
const vec3 terrainExtents = vec3(50, 3, 50);

vec3 toLight = normalize(vec3(sin(iGlobalTime + 2.0), 0.6, cos(iGlobalTime + 2.0)));

vec3 backgroundColor(const vec3 dir)
{
	float sun = max(0.0, dot(dir, toLight));
	float sky = max(0.0, dot(dir, vec3(0.0, 1.0, 0.0)));
	float ground = max(0.0, -dot(dir, vec3(0.0, 1.0, 0.0)));
	return 
  (pow(sun, 256.0) + 0.2 * pow(sun, 2.0)) * vec3(2.0, 1.6, 1.0) +
  pow(ground, 0.5) * vec3(0.4, 0.3, 0.6) +
  pow(sky, 1.0) * vec3(0.5, 0.6, 1);
}

vec2 toTextureSpace(vec3 p)
{
	vec2 minCorner = terrainBottomCenter.xz - 0.5 * terrainExtents.xz;
	vec2 ts = (p.xz - minCorner) / terrainExtents.xz;
	return ts;
}

float f(vec3 p)
{
	vec2 uv = toTextureSpace(p);
	float func = texture(tex0, uv).x;
	func = sin(uv.x * 100) * cos(uv.y * 100) * 0.5 + 0.5; //analytical height field
	return func * terrainExtents.y + terrainBottomCenter.y;
}

vec3 colorF(vec3 p)
{
	return texture(tex1, toTextureSpace(p)).rgb;
}

float rayMarchingBisection(Ray ray, float minT, float maxT, int count)
{
	float t;
	for(int i = 0; i < count; ++i)
	{
		float middle = 0.5 * (minT + maxT);
		vec3 p = ray.origin + middle * ray.dir;
		if( p.y < f( p ) )
		{
			//inside
			maxT = middle;
		}
		else
		{
			//outside
			minT = middle;
		}
		t = middle;
	}
	return t;
}

float rayMarching(Ray ray, float minT, float delta, int maxSteps, out int steps)
{
	steps = 0;
	for(float t = minT; steps < maxSteps; t += delta)
	{
		++steps;
		vec3 p = ray.origin + t * ray.dir;
		if( p.y < f( p ) )
		{
			//inside
			// return t;
			steps += 5;
			return rayMarchingBisection(ray, t - delta, t, 5);
		}
		delta += 0.0003; //increase delta with distance
	}
	return BIGNUMBER;
}

vec3 getNormal(vec3 p, float delta)
{
    vec3 n;
	n.x = f(p - vec3(delta, 0, 0)) - f(p + vec3(delta, 0, 0));
	n.y = 2 * delta;
	n.z = f(p - vec3(0, 0, delta)) - f(p + vec3(0, 0, delta));
    return normalize(n);
}


vec3 getShading(vec3 p, vec3 n)
{
	// return n;
	vec3 color = colorF(p);
	// return color;
	return vec3(dot(toLight, n));
	return max(0, dot(toLight, n)) * color;
}

vec3 terrainColor(Ray ray, float t)
{
    vec3 p = ray.origin + t * ray.dir;
    vec3 n = getNormal( p, 0.031 );
    vec3 s = getShading( p, n );
    return s;
}

void main()
{
	vec3 camP = calcCameraPos();
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, u_resolution);
	Ray ray = Ray(camP, camDir);

	int maxSteps = 1000;
	int steps;
	float t = rayMarching(ray, 0, 0.1, maxSteps, steps);
	vec3 color = t < BIGNUMBER ? terrainColor(ray, t): backgroundColor(camDir);
	// color = mix(vec3(0, 1, 0), vec3(1, 0, 0), steps / float(maxSteps)); //effort
	gl_FragColor = vec4(color, 1.0);
}


