#version 420

#include "../libs/camera.glsl"
#include "../libs/rayIntersections.glsl"

uniform vec2 u_resolution;
uniform float iGlobalTime;
in vec2 uv;

const float bigNumber = 1e4;
const float eps = 1e-5;
vec3 toLight = normalize(vec3(sin(iGlobalTime + 2.0), 0.6, cos(iGlobalTime + 2.0)));
const vec3 lightColor = vec3(1, 1, 0.9);
const vec3 lightColorAmbient = vec3(0.15, 0.15, 0);

const int PLANE = 0;
const int SPHERE = 1;
const int BOX = 2;

const float DIFFUSE = 0.0;
const float REFLECTIVE = 1.0;

struct Object
{
	vec4 data;
	int type; //PLANE, SPHERE, BOX, ...
	float materialType; // 0 == diffuse
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
			scene.objects[i] = Object(vec4(newM, 0.3), 0 == i % 2 ? SPHERE : BOX, REFLECTIVE);
			++i;
		}
	}
	scene.objects[i++] = Object(vec4(vec3(0.0, 1.0, 0.0), .5), PLANE, DIFFUSE);
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
	bool hitObject;
	float materialType;
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
	Object obj = scene.objects[hit.objectId];
	if(hit.tMin < bigNumber) return color;
	
	//diffuse
	float lambert = dot(state.n, toLight);
	if(0 > lambert) return color; //backside
	return color + lightColor * state.color * lambert;
	
	//no need for specular -> we have real reflections
}

TraceState traceStep(Ray ray)
{
	Hit hit = findNearestObjectHit(ray);
	TraceState state;
	state.hitObject = hit.tMin < bigNumber;
	vec3 bckgroundColor = backgroundColor(ray.dir);
	if(state.hitObject) 
	{
		Object obj = scene.objects[hit.objectId];
		state.materialType = obj.materialType;
		state.point = ray.origin + hit.tMin * ray.dir;
		state.n = normal(obj, state.point);
		state.n *= -sign(dot(state.n, ray.dir));
		state.dirIn = ray.dir;
		state.color = objectColor(obj, state);
		state.color = directLighting(state);
	}
	else 
	{
		state.color = bckgroundColor;
	}
	return state;
}

TraceState reflection(const TraceState state)
{
	vec3 r = reflect(state.dirIn, state.n);
	vec3 stableRayO = state.point + state.n * eps;
	TraceState stateOut = traceStep(Ray(stableRayO, r));
	return stateOut;
}

void main()
{
	vec3 camP = calcCameraPos();
	vec3 camDir = calcCameraRayDir(70.0, gl_FragCoord.xy, u_resolution);
	
	//primary ray
	TraceState state = traceStep(Ray(camP, camDir));
	vec3 color = state.color;
	for(int i = 1; i <= 4; ++i)
	{
		if(!state.hitObject || DIFFUSE == state.materialType) break;
		state = reflection(state);
		color += state.color * pow(.6, i);
	}

	gl_FragColor = vec4(color, 1.0);
}


