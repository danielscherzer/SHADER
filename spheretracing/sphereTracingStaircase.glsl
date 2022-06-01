#version 330

#include "../libs/camera.glsl"
#include "../libs/operators.glsl"

uniform vec2 u_resolution;
uniform float iGlobalTime;

const float epsilon = 1e-6;
const int maxSteps = 256;

float DFBox(vec3 point, vec3 origin, vec3 size, float roundness)
{
    vec3 d = abs(point - origin) - size;
    return length(max(d, 0.0)) - roundness
        + min(max(d.x,max(d.y,d.z)),0.0);
}

float stairs(vec3 point)
{
    // room
    vec3 roomSize = vec3(2.0, 1.5, 20.0);
    vec3 roomOrigin = vec3(0.0, 1.5, 0.0);

    vec3 roomPoint = point;
    float stepCount = 5.0;
    float stepDepth = 0.30;
    float stepHeight = 0.18;
    float stairIndex = ceil((1.0 / stepDepth) * (point.z - 4.0));
    // roomPoint.y -= clamp(stairIndex * stepHeight, 0.0, stepCount * stepHeight);

	return DFBox(roomPoint, roomOrigin, roomSize, 0.0);
}

float distField(vec3 point)
{
	float height = ceil(4 * point.z) * 0.1;
	float bigBox = sBox(point, vec3(0, -1, 0), vec3(1, height, 1));
	return bigBox;
	vec3 repXY = opRepeatCentered(point, vec3(.5, .5, 1));
	float dist2 = sBox(repXY, vec3(0, 0, 0), vec3(0.1, 0.1, 10));
	// return dist2;
	vec3 repYZ = opRepeatCentered(point, vec3(1, .5, .5));
	float dist3 = sBox(repYZ, vec3(0, 0, 0), vec3(10, 0.1, 0.1));
	// return dist3;
	float distCutOut = opUnion(dist2, dist3);
	// return distCutOut;
	float building = opDifference(bigBox, distCutOut);

	return building;
	return stairs(point);
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
	camP.z -= 2;
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