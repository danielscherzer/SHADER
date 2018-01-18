#version 330
#include "../libs/camera.glsl"

uniform vec2 iResolution;

const float epsilon = 0.0001;
const int maxSteps = 32;

float dist2sphere(vec3 point, vec3 center, float radius) 
{
    return length(point - center) - radius;
}

float distFunc(vec3 point)
{
	return dist2sphere(point, vec3(0, 0, 1), 0.3);
}

void main()
{
	vec3 camP = calcCameraPos();
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, iResolution);

	//start point is the camera position
	vec3 point = camP; 	
	bool objectHit = false;
	float t = 0.0;
	//step along the ray 
    for(int steps = 0; steps < maxSteps; ++steps)
    {
		//check how far the point is from the nearest surface
        float dist = distFunc(point);
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

	if(objectHit)
	{
		gl_FragColor = vec4(0, 0, 1, 1);
	}
	else
	{
		gl_FragColor = vec4(0, 0, 0, 1);
	}
}