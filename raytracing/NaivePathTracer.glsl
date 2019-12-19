#version 120

#include "../libs/camera.glsl"

uniform vec3 iMouse;
uniform vec2 u_resolution;
uniform float iGlobalTime;
float time = iGlobalTime;
// based on: but switched out most of the math
// Simple path tracer. Created by Reinder Nijhoff 2014
// @reindernijhoff
//
// https://www.shadertoy.com/view/4tl3z4

const float PI = 3.1415926535897932384626433832795;
const float TWOPI = 2 * PI;
const float BIG_NUMBER = 1e20;

#define eps 0.0001
#define EYEPATHLENGTH 6
#define SAMPLES 200

#define LIGHTCOLOR vec3(16.86, 10.76, 8.2) * 1.3
#define WHITECOLOR vec3(.7295, .7355, .729) * 0.7
#define GREENCOLOR vec3(.117, .9125, .115) * 0.7
#define REDCOLOR vec3(.611, .0555, .062) * 0.7

const vec4 SPHERE1 = vec4( 1.5, 1.0, 2.7, 1.0);
const vec4 SPHERE2 = vec4( 4.0, 1.0, 4.0, 1.0);
const vec4 SPHERE3 = vec4( 3.0, 4.0, 4.0, 1.0);

const float lightSize = 0.5;
vec4 lightSphere;

float seed; //global seed value for random functions

const vec3 magicRandom = vec3(43758.5453123, 22578.1459123, 19642.3490423);

float hash1()
{
    return fract(sin(seed += 0.1) * magicRandom.x);
}

vec2 hash2()
{
    return fract(sin(vec2(seed+=0.1,seed+=0.1)) * magicRandom.xy);
}

vec3 hash3()
{
    return fract(sin(vec3(seed+=0.1,seed+=0.1,seed+=0.1)) * magicRandom);
}

//-----------------------------------------------------
// Intersection functions (by iq)
//-----------------------------------------------------

vec3 nSphere( const vec3 pos, const vec4 sph ) 
{
    return (pos-sph.xyz)/sph.w;
}

float iSphere( const vec3 ro, const vec3 rd, const vec4 sph ) 
{
    vec3 oc = ro - sph.xyz;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - sph.w * sph.w;
    float h = b * b - c;
    if (h < 0.0) return -1.0;

	float s = sqrt(h);
	float t1 = -b - s;
	float t2 = -b + s;
	
	return t1 < 0.0 ? t2 : t1;
}

vec3 nPlane( const vec3 ro, const vec4 obj ) 
{
    return obj.xyz;
}

float iPlane( const vec3 ro, const vec3 rd, const vec4 pla ) 
{
    return (-pla.w - dot(pla.xyz,ro)) / dot( pla.xyz, rd );
}

//-----------------------------------------------------
// scene
//-----------------------------------------------------
void update(const float t, const float material, const vec3 normal, inout vec2 res, inout vec3 newNormal)
{
	if( t > eps && t < res.x ) //intersection only if more than epsilon away
	{ 
		res = vec2( t, material); 
		newNormal = normal; 
	}
}

float intersect( const vec3 ro, const vec3 rd, inout vec3 normal, out float material ) 
{
	vec2 res = vec2( BIG_NUMBER, -1.0 );
    float t;
	
	t = iPlane( ro, rd, vec4( 0.0, 1.0, 0.0,0.0 ) ); update(t, 1., vec3( 0., 1., 0.), res, normal);
	t = iPlane( ro, rd, vec4( 0.0, 0.0,-1.0,8.0 ) ); update(t, 5., vec3( 0., 0.,-1.), res, normal);
    t = iPlane( ro, rd, vec4( 1.0, 0.0, 0.0,0.0 ) ); update(t, 2., vec3( 1., 0., 0.), res, normal);
    t = iPlane( ro, rd, vec4( 0.0,-1.0, 0.0,5.49) ); update(t, 1., vec3( 0., -1., 0.), res, normal);
    t = iPlane( ro, rd, vec4(-1.0, 0.0, 0.0,5.59) ); update(t, 3., vec3(-1.,  0., 0.), res, normal);

	t = iSphere( ro, rd, SPHERE1 ); update(t, 5., nSphere( ro+t*rd, SPHERE1 ), res, normal);
    t = iSphere( ro, rd, SPHERE2 ); update(t, 6., nSphere( ro+t*rd, SPHERE2 ), res, normal); 
    t = iSphere( ro, rd, SPHERE3 ); update(t, 1., nSphere( ro+t*rd, SPHERE3 ), res, normal);  
    t = iSphere( ro, rd, lightSphere ); update(t, 0., nSphere( ro+t*rd, lightSphere ), res, normal);  
					  
	material = res.y;
    return res.x;					  
}

//-----------------------------------------------------
// materials
//-----------------------------------------------------
vec3 matColor( const float mat ) 
{
	vec3 nor = vec3(0.4, 0.95, 0.9);
	
	if( mat<3.5 ) nor = REDCOLOR;
    if( mat<2.5 ) nor = GREENCOLOR;
	if( mat<1.5 ) nor = WHITECOLOR;
	if( mat<0.5 ) nor = LIGHTCOLOR;
					  
    return nor;					  
}

bool matIsRefractive( const float mat ) 
{
    return mat > 5.5;
}

bool matIsSpecular( const float mat ) 
{
    return mat > 4.5;
}

bool matIsLight( const float mat ) 
{
    return mat < 0.5;
}

vec3 randomHemisphereDirection() 
{
  	vec2 rnd = hash2(); //range [0,1]²

	//spherical coordiantes to cartesian
	float r = sqrt(1.0 - rnd.x * rnd.x);
	float phi = TWOPI * rnd.y;

	return (vec3( r * cos(phi), r * sin(phi), rnd.x));
}

vec3 cosWeightedRandomHemisphereDirection() 
{
  	vec2 rnd = hash2(); //range [0,1]²

	//The common way to generate a cosine weighted hemisphere sampler is to generate uniform points on a disk, and then project them up to the hemisphere.
	float r = sqrt(rnd.x);
	float theta = TWOPI * rnd.y;
	float z = sqrt(1.0 - rnd.x);

	return (vec3( r * cos(theta), r * sin(theta), z));
}

// This function is based on the CoordinateSystem function from PBRT v2, p63 
mat3 coordinateSystem(const vec3 v1) 
{
	vec3 v2 = normalize(abs(v1.x) > abs(v1.y) ? 
		vec3(-v1.z, 0.0, v1.x) :
		vec3(0.0, v1.z, -v1.y)); 

	vec3 v3 = cross(v1, v2);
	return mat3(v2, v3, v1);
}

vec3 getBRDFRay( in vec3 n, const vec3 dirIn, const float material ) 
{
    bool specularBounce = matIsSpecular(material);
    
    if( !specularBounce )
	{
		return coordinateSystem( n ) * cosWeightedRandomHemisphereDirection(); //diffuse
    } 
	else 
	{
		if(matIsRefractive(material))
		{	//refractive
			float n1, n2, ndotr = dot(dirIn, n);
			//outside-in or inside-out
			if( ndotr > 0.0 )
			{
				n1 = 1.0/1.5; n2 = 1.0;
				n = -n;
			}
			else 
			{
				n2 = 1.0/1.5; n1 = 1.0;
			}
			//fresnel schlick approximation
			float r0 = (n1 - n2) / (n1 + n2); 
			r0 *= r0;
			float fresnel = r0 + (1.0 - r0) * pow(1.0 - abs(ndotr), 5.0);
			//choose reflection or refraction according to Fresnel and random threshold
			return hash1() < fresnel ? reflect( dirIn, n ) : refract( dirIn, n, n2/n1 );
		}
		return reflect( dirIn, n ); //reflective
	}
}

vec3 traceEyePath( in vec3 ro, in vec3 rd ) 
{
    vec3 color = vec3(1.0);
    
    for(int i = 0; i < EYEPATHLENGTH; ++i) 
	{
		vec3 normal;
		float material;
        float t = intersect( ro, rd, normal, material );
		if(!(t < BIG_NUMBER)) break; //nothing hit
        if( matIsLight( material ) ) 
		{	//hit light source
            return color * LIGHTCOLOR;
        }
        
        ro = ro + t * rd; // next intersection point
        rd = getBRDFRay( normal, rd, material ); //new ray direction from brdf
        color *= matColor( material ); // material color interaction
    }    
    return vec3(0); //did not hit light source -> black ray
}

mat3 lookAt(vec3 position, vec3 target)
{
	vec3 up = vec3(0.0, 1.0, 0.0); //start with y-axis up vector
	//camera basis with Gram-Schmidt orthogonalization
    vec3 ww = normalize( target - position ); //view direction
    vec3 uu = normalize( cross(ww, up ) ); //right vector
    vec3 vv = normalize( cross(uu, ww) ); //up vector
	return mat3(uu, vv, ww);
}

void main()
{
    vec2 p = -1.0 + 2.0 * (gl_FragCoord.xy) / u_resolution.xy; //coordinate range [-1, 1]²
    p.x *= u_resolution.x / u_resolution.y; //aspect correction
    
	vec3 cameraPos = vec3(2.78, 2.73, -8.00);
    vec3 cameraTarget = vec3(2.78, 2.73,  0.00);
	mat3 camera = lookAt(cameraPos, cameraTarget);

	lightSphere = vec4( 3.0 + 2.0 * sin(time), 2.8 + 2.0 * sin(time * 0.9), 3.0 + 4.0 * cos(time * 0.7), lightSize ); //update light position    

    seed = gl_FragCoord.x + gl_FragCoord.y * 3.43121412313; //each pixel gets its own random seed
    
    vec3 color = vec3(0.0); // for color accumulation
    for( int i = 0; i < SAMPLES; ++i ) // loop over samples
	{
		//generate random ray direction for sample
        vec2 rayDelta = 4.0 * (hash2() - vec2(0.5)) / u_resolution.xy;
		vec3 rd = normalize(camera * vec3(p + rayDelta, 3.0)); //rotate ray dir with camera basis; big z for smaller fov
        
        color += traceEyePath( cameraPos, rd );
        
        seed = mod( seed * 1.1234567893490423, 13. ); //change seed each iteration
    }
    
    color /= float(SAMPLES); // divide by sample count
    
	color = pow( clamp(color, 0.0, 1.0), vec3(0.45) ); //gamma correction
    gl_FragColor = vec4( color, 1.0 );
}

