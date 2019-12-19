#version 330

#include "../libs/camera.glsl"
#include "../libs/hg_sdf.glsl"
#include "../libs/operators.glsl"

uniform vec2 u_resolution;
uniform float iGlobalTime;

const float epsilon = 0.001;
const int maxSteps = 512;

float Mandelbulb(vec3 pos) {
	int iterations = 10;
	float bailout = 2;
	float Power = 8;
	vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < iterations ; i++) {
		r = length(z);
		if (r>bailout) break;
		
		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow( r, Power-1.0)*Power*dr + 1.0;
		
		// scale and rotate the point
		float zr = pow( r,Power);
		theta = theta*Power;
		phi = phi*Power;
		
		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=pos;
	}
	return 0.5*log(r)*r/dr;
}

float DE(vec3 z)
{
	int iterations = 10;
	float Offset = 0.315;
	float scale = 2;
    float r;
    int n = 0;
    while (n < iterations) {
       if(z.x+z.y<0) z.xy = -z.yx; // fold 1
       if(z.x+z.z<0) z.xz = -z.zx; // fold 2
       if(z.y+z.z<0) z.zy = -z.yz; // fold 3	
       z = z*scale - Offset*(scale-1.0);
       n++;
    }
    return (length(z) ) * pow(scale, -float(n));
}

float distField(vec3 point)
{
// point /= 10;
float mandelbulb = Mandelbulb(point);
float plane = fPlane(point, vec3(1, 0, 0), 0);
return mandelbulb;
return DE(point);
	int iterations = 10;
	float scale = 0.1;
	vec3 a1 = vec3(1, 1, 1);
	vec3 a2 = vec3(-1, -1, 1);
	vec3 a3 = vec3(1, -1, -1);
	vec3 a4 = vec3(-1, 1, -1);
	int n = 0;
	for(; n < iterations; ++n) 
	{
		vec3 c = a1; 
		float dist = length(point - a1);
	    float d = length(point - a2);
		if (d < dist) 
		{ 
			c = a2; 
			dist = d;
		}
		d = length(point - a3); 
		if (d < dist) 
		{
			c = a3; 
			dist = d;
		}
		d = length(point - a4);
		if (d < dist) 
		{ 
			c = a4; 
			dist = d; 
		}
		point = scale * point - (scale - 1.0) * c;
	}
	return length(point) * pow(scale, float(-n));
}



float ambientOcclusion(vec3 point, float delta, int samples)
{
	vec3 normal = getNormal(point, 0.0001);
	float occ = 0;
	for(int i = 1; i < samples; ++i)
	{
		occ += (8.0/i) * (i * delta - distField(point + i * delta * normal));
	}
	// occ = clamp(occ, 0, 1);
	return 1 - occ;
}

void main()
{
	vec3 camP = calcCameraPos();
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, u_resolution);

	//start point is the camera position
	vec3 point = camP; 	
	bool objectHit = false;
	float t = 0.0;
	//step along the ray 
    for(int steps = 0; steps < maxSteps && t < 10; ++steps)
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

	vec3 color = vec3(0, 0, 1);
	if(objectHit)
	{
		vec3 material = vec3(1); //white
		//the usual lighting is boring
		vec3 normal = getNormal(point, 0.01);
		vec3 lightDir = normalize(vec3(0, -1.0, 1));
		vec3 toLight = -lightDir;
		float diffuse = max(0, dot(toLight, normal));
		vec3 ambient = vec3(0.1);

		// color = ambient + diffuse * material;
		color = ambientOcclusion(point, 0.01, 10) * material;
		// color = material;
	}
	//fog
	// float tmax = 10.0;
	// float factor = t/tmax;
	// factor = clamp(factor, 0.0, 1.0);
	// color = mix(color, vec3(1.0, 0.8, 0.1), factor);
	gl_FragColor = vec4(color, 1);
}