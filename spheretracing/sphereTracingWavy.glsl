#version 330

#include "../libs/camera.glsl"

uniform vec2 iResolution;
uniform float iGlobalTime;

const float epsilon = 0.0001;
const int maxSteps = 128;

float sPlane(vec3 point, vec3 normal, float d) {
	return dot(point, normal) - d;
}

float sSphere(vec3 point, vec3 center, float radius) {
	return length(point - center) - radius;
}

vec3 opCoordinateRepetition(vec3 point, vec3 c)
{
	return mod(point, c) - 0.5 * c;
}


float distScene(vec3 point)
{
	point.y += sin(point.z - iGlobalTime * 6.0) * cos(point.x - iGlobalTime) * .25; //waves! line iii
	float distPlane = sPlane(point, vec3(0.0, 1.0, 0.0), -0.5);
	point = opCoordinateRepetition(point, vec3(1.0, 1.0, 1.0));
	float distSphere = sSphere(point, vec3(0.0, 0.0, 0.0), 0.2);
	return min(distPlane, distSphere);
}

//by numerical gradient
vec3 getNormal(vec3 point)
{
	float d = epsilon;
	//get points a little bit to each side of the point
	vec3 right = point + vec3(d, 0.0, 0.0);
	vec3 left = point + vec3(-d, 0.0, 0.0);
	vec3 up = point + vec3(0.0, d, 0.0);
	vec3 down = point + vec3(0.0, -d, 0.0);
	vec3 behind = point + vec3(0.0, 0.0, d);
	vec3 before = point + vec3(0.0, 0.0, -d);
	//calc difference of distance function values == numerical gradient
	vec3 gradient = vec3(distScene(right) - distScene(left),
		distScene(up) - distScene(down),
		distScene(behind) - distScene(before));
	return normalize(gradient);
}

void main()
{
	vec3 camP = calcCameraPos();
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, iResolution);
	
	vec3 point = camP;
	bool objectHit = false;
	float t = 0.0;
	for(int steps = 0; steps < maxSteps; ++steps)
	{
		float dist = distScene(point);
		if(epsilon > dist)
		{
			objectHit = true;
			break;
		}
		t += dist;
		point = camP + t * camDir;
	}
	vec3 color = vec3(0.0, 0.0, 0.0);
	if(objectHit)
	{
		vec3 lightDir = normalize(vec3(cos(iGlobalTime), 1.0, sin(iGlobalTime)));
		vec3 normal = getNormal(point);
		float lambert = max(0.2 ,dot(normal, lightDir));
		color = lambert * vec3(1.0);
	}
	//fog
	float tmax = 10.0;
	float factor = t/tmax;
	// factor = clamp(factor, 0.0, 1.0); //line i
	color = mix(color, vec3(1.0, 0.8, 0.1), factor); //line ii
	
	gl_FragColor = vec4(color, 1.0);
}


