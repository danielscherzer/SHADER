#version 330

#include "../libs/camera.glsl"
#include "../libs/operators.glsl"
#include "../libs/Noise.glsl"
#include "../libs/Noise2D.glsl"
#include "../libs/Noise3D.glsl"
#include "../libs/hg_sdf.glsl"

uniform vec2 u_resolution;
uniform float iGlobalTime;

const float epsilon = 0.0001;
const int maxSteps = 256;
const float miss = -10000;

float distTree(vec3 point)
{
	float bark = snoise(point * 30) * 0.005;
	float height = 3;// + 0*rand(ceil(point.xz + 0.5)) * 3; //trunk height
	float thickness =  0.4;// + 0*rand(ceil(point.xz - 0.5)) * 0.2; //trunk thickness
	float bending = gnoise(point.y + point.xz) * 0.1; // trunk bending
	point.xz += bending;

	point = opRepeat(point, vec3(4, 0, 4));
	float cylinder = fCylinder(point, thickness, height);
	return cylinder + bark;
}

float distTerrain(vec3 point)
{
	float yDisplacement  = 0.0;
	yDisplacement = snoise(point.xz * 0.1) * 4;
	yDisplacement+= snoise(point.xz * 0.3) * 0.5;
	yDisplacement+= snoise(point.xz) * 0.1;
	point.y += yDisplacement * 0.4; // bad distance field -> keep gradient low
	return sPlane(point, vec3(0.0, 1.0, 0.0), -0.5);
}

float distField(vec3 point)
{
	float terrain = distTerrain(point);
	return terrain;
	float trees = distTree(point);
	return smin(terrain, trees, 0.9);
}

vec3 colorField(vec3 point)
{
	float terrain = distTerrain(point);
	float trees = distTree(point);
	float blend = smin(terrain, trees, 0.9);
	
	float weight = (blend - terrain) / (trees - terrain);
	weight = clamp(weight, 0, 1);
	
	vec3 colorTerrain = vec3(0.1, 0.4, 0);
	vec3 colorTree = vec3(0.6, 0.4, 0.2);
	// if(blend == terrain) return colorTerrain;
	// if(blend == trees) return colorTree;
	// return vec3(0,0,1);
	return mix(colorTerrain, colorTree, weight);
}

float sphereTracing(vec3 O, vec3 dir, float maxT, int maxSteps)
{
	float t = 0.0;
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

vec3 rayMarchVolumetric(vec3 O, vec3 dir, float opaqueT, vec3 opaqueColor)
{
	float deltaT = 1;
	float densityFact = 1 / (opaqueT / deltaT);
	vec4 dst = vec4(0);
	for(float t = 0; t < opaqueT; t += deltaT)
    {
		vec3 point = O + t * dir;
		float value = snoise(point * 0.5) * densityFact;
		
		vec4 src = vec4(value);
		// src.a *= .5f; //reduce the alpha to have a more transparent result 

		//Front to back blending
		// dst.rgb = dst.rgb + (1 - dst.a) * src.a * src.rgb
		// dst.a   = dst.a   + (1 - dst.a) * src.a     
		src.rgb *= src.a;
		dst = (1 - dst.a) * src + dst;     

		//break from the loop when alpha gets high enough
		if(dst.a >= .95f) break; 
	}
	return (1 - dst.a) * opaqueColor + dst.rgb;
}

void main()
{
	vec3 camP = calcCameraPos();
	camP.y += 4;
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, u_resolution);

	float maxT = 100;
	//start point is the camera position
	float t = sphereTracing(camP, camDir, maxT, maxSteps);
	
	vec3 color = vec3(0);
	if(0 < t)
	{
		vec3 point = camP + t * camDir;
		vec3 normal = getNormal(point, 0.001);
		vec3 lightDir = normalize(vec3(1, -1, 1));
		vec3 toLight = -lightDir;
		float diffuse = max(0, dot(toLight, normal));
		vec3 material = colorField(point);
		vec3 ambient = vec3(0);

		color = ambient + diffuse * material;
		//color = material;
		float weight = t / maxT;
		color = mix(color, vec3(0), pow(weight, 2)); //fog
		// color = vsec3(1 - abs(acos(dot(normal, vec3(0,1,0)))));
	}
	//color = rayMarchVolumetric(camP, camDir, t, color);
	gl_FragColor = vec4(color, 1);
}