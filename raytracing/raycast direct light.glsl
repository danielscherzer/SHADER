#version 420

#include "../libs/camera.glsl"
#include "../libs/rayIntersections.glsl"

uniform vec2 u_resolution;
uniform float iGlobalTime;
in vec2 uv;

const float bigNumber = 10000.0;
const float eps = 1e-5;
vec3 toLight = normalize(vec3(sin(iGlobalTime + 2.0), 0.6, cos(iGlobalTime + 2.0)));
const vec3 lightColor = vec3(1, 1, 1);
const vec3 lightColorAmbient = vec3(0.15, 0.15, 0);

const int PLANE = 0;
const int SPHERE = 1;
const int BOX = 2;

struct Object
{
	vec4 data;
	int type; //PLANE, SPHERE, BOX, ...
	float shininess; // 0 == diffuse
};

const int OBJECT_COUNT = 9;
struct Scene
{
	Object objects[OBJECT_COUNT];
};

float cube(const vec3 center, const float halflength, const Ray ray, const float EPSILON)
{
	vec3 minP = center + vec3(halflength);
	vec3 maxP = center - vec3(halflength);
	return box(minP, maxP, ray, EPSILON);
}

Scene buildScene()
{
	const vec3 delta = vec3(-0.5, -.2, 0);
	Scene scene;
	int i = 0;
	for(float z = delta.z + 1.0; z <= delta.z + 4.0; z += 1.0)
	{
		float y = delta.y;
		for(float x = delta.x; x <= delta.x + 1.0; x += 1.0)
		{	
			vec3 newM = vec3(x, y, z);
			scene.objects[i] = Object(vec4(newM, 0.3), 0 == i % 2 ? SPHERE : BOX, 128);
			++i;
		}
	}
	scene.objects[i] = Object(vec4(vec3(0.0, 1.0, 0.0), .5), PLANE, 0);
	++i;
	return scene;
};

Scene scene = buildScene();

vec3 backgroundColor(const vec3 dir)
{
	float sun = max(0.0, dot(dir, toLight));
	float sky = max(0.0, dot(dir, vec3(0.0, 1.0, 0.0)));
	float ground = max(0.0, -dot(dir, vec3(0.0, 1.0, 0.0)));
	return 
  (pow(sun, 256.0) + 0.2 * pow(sun, 2.0)) * vec3(2.0, 1.6, 1.0) +
  pow(ground, 0.5) * vec3(0.4, 0.3, 0.2) +
  pow(sky, 1.0) * vec3(0.5, 0.6, 0.7);
}

float intersect(const Object obj, const Ray ray)
{
	switch(obj.type)
	{
		case 0: //plane
			return plane(obj.data.xyz, obj.data.w, ray, eps);
		case 1: //sphere
			return sphere(obj.data.xyz, obj.data.w, ray, eps);
		case 2: //cube
			return cube(obj.data.xyz, obj.data.w, ray, eps);
		default:
			return -bigNumber;
	}
}

struct TraceState
{
	float shininess;
	vec3 n;
	vec3 color;
	vec3 point;
	vec3 dirIn;
};

vec3 objectColor(const Object obj, const TraceState state)
{
	switch(obj.type)
	{
		case 0: //plane
			vec2 p = floor(state.point.xz * 8.0);
			float checker = mod(p.x + p.y, 2.0);
			vec2 width = fwidth(state.point.xz * 16.0);
			float widthMax = max(width.s, width.t);
			float weight = smoothstep(0.5, 0.5 + widthMax, checker);
			return mix(vec3(0.5), vec3(1), weight);
		case 1: //sphere
			return abs(normalize(obj.data.xyz - vec3(1.0, 0.0, 2.0)));
		case 2: //cube
			return abs(normalize(obj.data.xyz - vec3(1.0, 1.0, 2.0)));
		default:
			return vec3(1);
	}
}

vec3 normal(const Object obj, const vec3 point)
{
	switch(obj.type)
	{
		case 0: //plane
			return obj.data.xyz;
		case 1: //sphere
			return sphereNormal(obj.data.xyz, point);
		case 2: //cube
			return boxNormal(obj.data.xyz, point);
		default:
			return vec3(0);
	}
}

struct Hit
{
	int objectId;
	float tMin;
};

Hit findNearestObjectHit(const Ray ray)
{
	Hit hit = Hit(-1, bigNumber);
	for(int id = 0; id < OBJECT_COUNT; ++id)
	{
		Object obj = scene.objects[id];
		float t = intersect(obj, ray);
		if(0 < t && t < hit.tMin)
		{
			hit.tMin = t;
			hit.objectId = id;
		}
	}
	return hit;
}

vec3 directLighting(const TraceState state)
{
	//ambient
	vec3 color = lightColorAmbient * state.color;

	//shadow ray
	vec3 stableRayO = state.point + state.n * eps;
	Hit hit = findNearestObjectHit(Ray(stableRayO, toLight));
	if(hit.tMin < bigNumber) return color;
	
	//diffuse
	float lambert = dot(state.n, toLight);
	if(0 > lambert) return color; //backside
	color += lightColor * state.color * lambert;
	
	//specular
	if(.1 > state.shininess) return color; //diffuse only  material
	vec3 r = reflect(toLight, state.n);
	float dotRV = dot(r, state.dirIn);
	if(0 > dotRV) return color; //specular highlight on back
	
	return color + lightColor * state.color * pow(dotRV, state.shininess);
}

void main()
{
	vec3 camP = calcCameraPos();
	vec3 camDir = calcCameraRayDir(70.0, gl_FragCoord.xy, u_resolution);
	
	//primary ray
	Ray ray = Ray(camP, camDir);

	vec3 color = vec3(0);
	//cast ray
	Hit hit = findNearestObjectHit(ray);
	if(hit.tMin < bigNumber) 
	{
		//object hit
		Object obj = scene.objects[hit.objectId];
		TraceState state;
		state.shininess = obj.shininess;
		state.point = ray.origin + hit.tMin * ray.dir;
		state.n = normal(obj, state.point);
		state.dirIn = ray.dir;
		state.color = objectColor(obj, state);
		color = directLighting(state);
	}
	else
	{
		color = backgroundColor(ray.dir);
	}

	gl_FragColor = vec4(color, 1.0);
}


