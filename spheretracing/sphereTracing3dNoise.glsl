#version 330

#include "../libs/camera.glsl"
#include "../libs/operators.glsl"
#include "../libs/noise3D.glsl"

uniform vec2 iResolution;
uniform float iGlobalTime;

const float epsilon = 0.0001;
const int maxSteps = 128;

//fractal Brownian motion
float fBm(vec3 coord) 
{
	int octaves = 2;
    float value = 0;
    float amplitude = 0.5;
	float lacunarity = 2;
	float gain = 0.3;
    for (int i = 0; i < octaves; ++i) {
        value += amplitude * abs(snoise(coord)) * 0.5;
        coord = coord * lacunarity;
        amplitude *= gain;
    }
    return value;
}

float distField(vec3 pos)
{
	return pos.y * 0.01 + fBm(pos); //line i
}

vec3 shade(vec3 point)
{
	vec3 normal = getNormal(point, 0.01);
	vec3 lightDir = normalize(vec3(1, -1.0, 1));
	vec3 toLight = -lightDir;
	float diffuse = max(0, dot(toLight, normal));
	vec3 material = vec3(abs(sin(point * 3))); //line ii; some location based color
	vec3 ambient = vec3(0);

	return ambient + diffuse * material;	
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
	int steps = 0;
    for(; (steps < maxSteps) && (t < 100); ++steps)
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

	float effort = steps;
	effort /= maxSteps;
	vec3 red = vec3(1, 0, 0);
	vec3 green = vec3(0, 1, 0);
	vec3 color = mix(green, red, effort);
	color = objectHit ? shade(point) : vec3(0);

	gl_FragColor = vec4(color, 1);
}