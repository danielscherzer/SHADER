#version 330

#include "../libs/camera.glsl"
#include "../libs/operators.glsl"
#include "../libs/Noise.glsl"
#include "../libs/Noise2D.glsl"
#include "../libs/Noise3D.glsl"
#include "../libs/hg_sdf.glsl"

uniform vec2 iResolution;
uniform float iGlobalTime;

const float epsilon = 0.0001;
const int maxSteps = 256;
const float miss = -10000;

float distTree(vec3 point)
{
	float bark = snoise(point * 30) * 0.005;
	float height = 7;// + 0*rand(ceil(point.xz + 0.5)) * 3; //trunk height
	float thickness =  0.4;// + 0*rand(ceil(point.xz - 0.5)) * 0.2; //trunk thickness
	float bending = gnoise(point.y + point.xz) * 0.1; // trunk bending
	point.xz += bending;

	point = opRepeat(point, vec3(4, 0, 4));
	float cylinder = fCylinder(point, thickness, height);
	return cylinder + bark;
}

float distTerrain(vec3 point)
{
	float displacement = snoise(point.xz * 0.1) * 1.2;
	displacement += snoise(point.xz * 0.3) * 0.15;
	
	displacement += smoothstep(0.7, 0, point.y) * snoise(point * 3) * 0.005;
	
	point.y += displacement; //creates an incorrect distance field -> keep gradient low
	return sPlane(point, vec3(0.0, 1.0, 0.0), 1);
}

float distWater(vec3 point)
{
	// vec2 move = point.zx;
	// move -= vec2(iGlobalTime * 0.5, iGlobalTime * 0.2);
	// move *= 10;
	// point.y += (sin(move.x) * cos(move.y)) * .03; //waves!
	return sPlane(point, vec3(0.0, 1.0, 0.0), 1);
}

bool enableWater = true;
float distField(vec3 point)
{
	float terrain = distTerrain(point);
	float trees = distTree(point);
	float land = smin(terrain, trees, 0.9); //let tree and terrain overlap, otherwise problems on water rendering
	if(enableWater)
	{
		float water = distWater(point);
		return min(water, land);
	}
	else return land;
}

float sphereTracing(vec3 O, vec3 dir, float minT, float maxT, int maxSteps)
{
	float t = minT;
	//step along the ray 
    for(int steps = 0; (steps < maxSteps) && (t < maxT); ++steps)
    {
		//calculate new point
		vec3 point = O + t * dir;
		//check how far the point is from the nearest surface
        float dist = distField(point);
		//if we are very close
        if(epsilon > dist)
        {
			return t;
            break;
        }
		//screen error decreases with distance
		// dist = max(dist, t * 0.001);
		//not so close -> we can step at least dist without hitting anything
		t += dist;
    }
	return miss;
}

const int idWater = 0;
const int idTree = 1;
const int idTerrain = 2;

vec3 material(int id)
{
	switch(id)
	{
		case idWater : return vec3(0.1, 0.1, 0.9);
		case idTerrain: return vec3(0.1, 0.4, 0);
		case idTree: return vec3(0.6, 0.4, 0.2);
	}
	return vec3(1);
}

int idField(vec3 point)
{
	float terrain = distTerrain(point);
	float trees = distTree(point);
	float land = smin(terrain, trees, 0.9);

	float weight = (land - terrain) / (trees - terrain);
	weight = clamp(weight, 0, 1);

	if(enableWater)
	{
		float water = distWater(point);
		float dist = min(water, land);
		if(dist == water) return idWater;
	}
	return int(mix(idTerrain, idTree, weight));
}

vec3 ambientDiffuse(vec3 material, vec3 normal)
{
	vec3 ambient = vec3(0);

	vec3 lightDir = normalize(vec3(1, -1, 1));
	vec3 toLight = -lightDir;
	float diffuse = max(0, dot(toLight, normal));
	
	return ambient + diffuse * material;
}

vec3 localShade(int id, vec3 normal)
{
	switch(id)
	{
		case idTerrain: return ambientDiffuse(vec3(1, 0.8, 0.4), normal);
		case idTree: return ambientDiffuse(vec3(1, 0.8, 0.4), normal);
		case idWater : return ambientDiffuse(vec3(0.1, 0.1, 0.7), normal);
	}
}

vec3 shade(int id, vec3 point, vec3 incidentDir, vec3 normal)
{
	vec3 color = localShade(id, normal);
	if(idWater == id) //reflections, but long compilation times
	{
		// vec3 r = reflect(incidentDir, normal);
		// enableWater = false;
		// float t = sphereTracing(point, r, 0, 100, 100);
		// if(0 < t)
		// {
			// vec3 point = point + t * r;
			// vec3 reflection = localShade(idField(point), normal);
			// color += reflection;
		// }
		// enableWater = true;
	}
	return color;
}


void main()
{
	vec3 camP = calcCameraPos();
	camP.y += 2;
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, iResolution);

	float maxT = 100;
	//start point is the camera position
	float t = sphereTracing(camP, camDir, 0, maxT, maxSteps);
	
	vec3 color = vec3(0);
	if(0 < t)
	{
		vec3 point = camP + t * camDir;
		int id = idField(point);
		vec3 normal = getNormal(point, 0.01);
		color = shade(id, point, camDir, normal);

		if(idWater == id)
		{
			enableWater = false;
			vec3 r = refract(camDir, normal, 1 / 1.33);
			float nextT = sphereTracing(point, r, 0, maxT, maxSteps);
			float rayLengthInWater = nextT;
			float weight = clamp(rayLengthInWater * rayLengthInWater, 0, 1);
			vec3 nextPoint = point + nextT * r;
			vec3 nextNormal = getNormal(nextPoint, 0.01);
			vec3 ground = shade(idField(nextPoint), nextPoint, camDir, nextNormal);
			color = mix(ground, color, weight);
		}
		float weight = t / maxT;
		color = mix(color, vec3(0), pow(weight, 2)); //fog
	}
	gl_FragColor = vec4(color, 1);
}