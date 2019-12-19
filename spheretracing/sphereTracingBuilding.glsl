#version 330

#include "../libs/camera.glsl"
#include "../libs/operators.glsl"

uniform vec2 u_resolution;

const float epsilon = 1e-3;
const int maxSteps = 256;

float distField(vec3 point)
{
	point.x += 11.0;
	point.z -= 12.0;
	float bigBox = sBox(point, vec3(0, 0, 0), vec3(10, 10, 10));
	// return dist1;
	vec3 repXY = opRepeatCentered(point, vec3(.5, .5, 1));
	float dist2 = sBox(repXY, vec3(0, 0, 0), vec3(0.1, 0.1, 10));
	// return dist2;
	vec3 repYZ = opRepeatCentered(point, vec3(1, .5, .5));
	float dist3 = sBox(repYZ, vec3(0, 0, 0), vec3(10, 0.1, 0.1));
	// return dist3;
	float distCutOut = opUnion(dist2, dist3);
	// return distCutOut;
	return opDifference(bigBox, distCutOut);
}

float ambientOcclusion(vec3 point, float delta, int samples)
{
	vec3 normal = getNormal(point, epsilon);
//	return dot(normal, normalize(vec3(1,1,-1)));
	float occ = 0;
	for(int i = 1; i < samples + 1; ++i)
	{
		occ += (i * delta - distField(point + i * delta * normal));
	}
	return 1 - occ;
}

out vec3 color;
void main()
{
	vec3 camP = calcCameraPos();
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, u_resolution);

	//start point is the camera position
	vec3 point = camP;
	bool objectHit = false;
	float t = 0.0;
	//step along the ray
	int steps = 0;
	for(; (steps < maxSteps); ++steps)
	{
//		if(t > 100) break; // t > constant can be very large and still it is much faster then without
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
//		t += max(dist, t * 0.001); // Screen error decreases with distance

		//calculate new point
		point = camP + t * camDir;
	}

	float effort = steps / maxSteps;
	vec3 red = vec3(1, 0, 0);
	vec3 green = vec3(0, 1, 0);
	color = mix(green, red, effort);
	color = objectHit ? ambientOcclusion(point, 0.02, 5) * vec3(1) : vec3(0);
}