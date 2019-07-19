#version 330

#include "../libs/camera.glsl"
#include "../libs/operators.glsl"

uniform vec2 iResolution;
uniform float iGlobalTime;
float iTime = iGlobalTime;

const float epsilon = 1e-4;
const int maxSteps = 256;
const int ITERATIONS = 5;

//adapted from  http://www.iquilezles.org/www/articles/menger/menger.htm

float maxcomp(in vec3 p ) { return max(p.x,max(p.y,p.z));}
float sdBox( vec3 p, vec3 b )
{
  vec3  di = abs(p) - b;
  float mc = maxcomp(di);
  return min(mc,length(max(di,0.0)));
}

float map( in vec3 p )
{
	const mat3 ma = mat3( 0.60, 0.00,  0.80,
						  0.00, 1.00,  0.00,
						 -0.80, 0.00,  0.60 );

	float d = sdBox(p, vec3(1.0));
    vec4 res = vec4( d, 1.0, 0.0, 0.0 );

    float ani = smoothstep( -0.2, 0.2, -cos(0.5 * iTime) );
	float off = 1.5 * sin( 0.01 * iTime );
	
    float s = 1.0;
    for( int m = 0; m < ITERATIONS; ++m)
    {
		p = mix( p, ma*(p+off), ani );
		vec3 a = mod( p*s, 2.0 )-1.0;
		s *= 3.0;
		vec3 r = abs(1.0 - 3.0 * abs(a));
		float da = max(r.x,r.y);
		float db = max(r.y,r.z);
		float dc = max(r.z,r.x);
		float c = ( min(da,min(db,dc) ) - 1.0) / s;

		
		if( c > d )
		{
			d = c;
			res = vec4( d, min(res.y,0.2*da*db*dc), (1.0+float(m))/4.0, 0.0 );
		}
	}
	return d;
//	return res;
}

float distField(vec3 point)
{
	return map(point);
}

float ambientOcclusion(vec3 point, float delta, int samples)
{
	vec3 normal = getNormal(point, 0.0001);
	float occ = 0;
	for(int i = 1; i < samples; ++i)
	{
		occ += (8.0/i) * (i * delta - distField(point + i * delta * normal));
	}
//	occ = clamp(occ, 0, 1);
	return 1.0 - occ;
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

	vec3 color = vec3(0);
	if(objectHit)
	{
		vec3 material = vec3(1); //white
		//the usual lighting is boring
		vec3 normal = getNormal(point, 0.0001);
		vec3 lightDir = normalize(vec3(0, -1.0, 1));
		vec3 toLight = -lightDir;
		float diffuse = max(0, dot(toLight, normal));
		vec3 ambient = vec3(0.1);

		color = ambient + diffuse * material;
		color *= ambientOcclusion(point, 0.01, 10) * material;
		// color = material;
	}
	//fog
	float tmax = 4.0;
	float factor = t/tmax;
	factor = clamp(factor * factor, 0.0, 1.0);
	color = mix(color, vec3(0.6, 0.8, 0.1), factor);
	gl_FragColor = vec4(color, 1);
}