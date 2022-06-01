#version 330

#include "../libs/camera.glsl"
#include "../libs/hg_sdf.glsl"
#include "../libs/operators.glsl"

uniform vec2 u_resolution;
uniform float iGlobalTime;

const float epsilon = 0.001;
const int maxSteps = 512;


float distTentacle(vec3 point)
{
	float rr = dot(point.xy, point.xy);
	float dist = 10e7;
	for(int i = 0; i < 3; ++i)
	{
		vec3 p2 = rotateY( point, TAU * i / 6.0 + 0.04 * rr  );
		p2.y -= 3 * rr * exp2(-10.0 * rr);
		vec3 p3 = rotateZ(p2, PI / 2);
		float cylinder = fCylinder(p3, 0.1, 30.0);
		dist = min( dist, cylinder );
	}
	return dist;
}

float distMonster(vec3 point)
 {
	float move = dot(point.xz, point.xz) * 0.2 * (sin(iGlobalTime));
	point. y += move;
	float tentacle = distTentacle(point);
	point.y -= 0.1;
	float sphere = fSphere(point, 0.35);
//	 return sphere;
//return tentacle;
//	 return min(tentacle, sphere);
	return smin(tentacle, sphere, 0.2 );
 }

float distColumns(vec3 point)
{
	point = opRepeat(point, vec3(2));
	point.xz *= point.y; //increase radius with y
	float cylinder = fCylinder(point, 0.2, 5.0);
	return cylinder;
}

float distField(vec3 point)
{
	float plane = fPlane(point, vec3(0, 1, 0), +0.1);
//	return plane;
	float columns = distColumns(point);
//	return columns;
//	return min(columns, plane);
	float monster = distMonster(point);
//	return monster;
	float d1 = min(plane, columns);
	return min(d1, monster);
}

float ambientOcclusion(vec3 point, float delta, int samples)
{
	vec3 normal = getNormal(point, 0.0001);
	float occ = 0;
	for(int i = 1; i < samples; ++i)
	{
		occ += (2.0/i) * (i * delta - distField(point + i * delta * normal));
	}
	//occ = clamp(occ, 0, 1);
	return 1 - occ;
}

out vec3 color;
void main()
{
	vec3 camP = calcCameraPos();
	camP.z += -3.0;
	camP.y += 0.3;
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, u_resolution);

	//start point is the camera position
	vec3 point = camP;
	bool objectHit = false;
	float t = 0.0;
	//step along the ray
	for(int steps = 0; steps < maxSteps; ++steps)
	{
		//check how far the point is from the nearest surface
		float dist = distField(point);
		//if we are very close
		if(epsilon > dist)
		{
			objectHit = true;
			break;
		}
		//not so close -> we can step at least dist without hitting anything
		t += dist;
		//calculate new point
		point = camP + t * camDir;
	}

	color = vec3(0, 0, 1);
	if(objectHit)
	{
		vec3 material = vec3(1); //white
		//the usual lighting is boring
		vec3 normal = getNormal(point, 0.001);
		vec3 lightDir = normalize(vec3(0, -1.0, 1));
		vec3 toLight = -lightDir;
		float diffuse = max(0, dot(toLight, normal));
		vec3 ambient = vec3(0.1);

		color = ambient + diffuse * material;
		color = ambientOcclusion(point, 0.01, 10) * material;
	}
	//fog
	float tmax = 10.0;
	float factor = t/tmax;
	factor = clamp(factor, 0.0, 1.0);
	color = mix(color, vec3(1.0, 0.8, 0.1), factor);
}
