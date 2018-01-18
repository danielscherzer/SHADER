#ifndef rayIntersections_glsl
#define rayIntersections_glsl

struct Ray
{
	vec3 origin; // origin of ray
	vec3 dir; // direction of ray (unit length assumed)
};

//c = center of sphere
//r = radius of sphere
//return t of smaller hit point
float sphere(const vec3 c, const float r, const Ray ray, const float EPSILON)
{
	vec3 MO = ray.origin - c;
	float dotDirMO = dot(ray.dir, MO);
	float root = dotDirMO * dotDirMO - dot(ray.dir, ray.dir) * (dot(MO, MO) - r * r);
	if(root < EPSILON)
	{
		return -1.0;
	}
	float p = -dot(ray.dir, MO);
	float q = sqrt(root);
    return (p - q) > 0.0 ? p - q : p + q;
}

//center = center of sphere
//P = some point in space
// return normal of sphere in direction of P
vec3 sphereNormal(const vec3 center, const vec3 P)
{
	return normalize(P - center);
}

//n = normal of plane
//d = distance to origin
float plane(const vec3 n, const float d, const Ray ray, const float EPSILON)
{
	float denominator = dot(n, ray.dir);
	if(abs(denominator) < EPSILON)
	{
		//no intersection
		return -1.0;
	}
	return (-d-dot(n, ray.origin)) / denominator;
}

float box(const vec3 minP, const vec3 maxP, const Ray ray, const float EPSILON)
{
	vec3 diffMin = minP - ray.origin;
	vec3 diffMax = maxP - ray.origin;
	vec3 t0 = diffMin / ray.dir;
	vec3 t1 = diffMax / ray.dir;
	vec3 n = min(t0, t1);
	vec3 f = max(t0, t1);
	float enter = max(n.x, max(n.y, n.z));
	float exit = min(f.x, min(f.y, f.z));
	if(enter > exit) return -1;
	if (0 < enter) return enter;
	return exit;
}

vec3 boxNormal(const vec3 center, const vec3 point)
{
	vec3 diff = point - center;
	vec3 a = abs(diff);
	int axis = a.x > a.y ? (a.z > a.x ? 2 : 0) : (a.z > a.y ? 2 : 1);
	diff[axis] *= 1e10;
	return normalize(diff);
}

#endif
