uniform vec2 iResolution;
uniform float iGlobalTime;

const float bigNumber = 10000.0;
const float eps = 0.001;
const float PI = 3.14159;

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

void main()
{
	//camera setup
	float fov = 90.0 * (PI / 180.0);
	float fx = tan(fov / 2) / iResolution.x;
	vec2 d = fx * (gl_FragCoord.xy * 2.0 - iResolution.xy);

	vec3 camP = vec3(0.0, 0.0, 0.0);
	vec3 camDir = normalize(vec3(d.x, d.y, 1.0));
	
	//intersection
	vec3 C = vec3(0, 0, 1);
	float t = sphere(C, 0.4, Ray(camP, camDir), eps);

	//final color
	vec3 color;
	if(t < 0)
	{
		//background
		color = vec3(0);
	}
	else
	{
		color = vec3(1);

		
		//sphere diffuse coloring
		// vec3 normal = sphereNormal(C, camP + t * camDir);
		// color = normal;
		// color = vec3(dot(normal,normalize(vec3(1, 1, -1))));
	}
	// gl_FragColor = vec4(camDir, 1.0);
	gl_FragColor = vec4(color, 1.0);
}


