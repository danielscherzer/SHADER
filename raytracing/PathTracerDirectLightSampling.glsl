#version 120

uniform vec2 iResolution;
uniform float iGlobalTime;
// based on:
// Simple path tracer. Created by Reinder Nijhoff 2014
// @reindernijhoff
//
// https://www.shadertoy.com/view/4tl3z4
//

const float PI = 3.1415926535897932384626433832795;
const float TWOPI = 2 * PI;

#define eps 0.0001
#define EYEPATHLENGTH 6
#define SAMPLES 100

// #define SHOWSPLITLINE
#define FULLBOX

#define DOF
#define ANIMATENOISE 
//#define MOTIONBLUR

#define MOTIONBLURFPS 12.

#define LIGHTCOLOR vec3(16.86, 10.76, 8.2)*1.3
#define WHITECOLOR vec3(.7295, .7355, .729)*0.7
#define GREENCOLOR vec3(.117, .9125, .115)*0.7
#define REDCOLOR vec3(.611, .0555, .062)*0.7

const vec4 SPHERE1 = vec4( 1.5, 1.0, 2.7, 1.0);
const vec4 SPHERE2 = vec4( 4.0, 1.0, 4.0, 1.0);
const vec4 SPHERE3 = vec4( 3.0, 4.0, 4.0, 1.0);

float seed = iGlobalTime;

const vec3 magicRandom = vec3(43758.5453123,22578.1459123,19642.3490423);

float hash1() {
    return fract(sin(seed += 0.1) * magicRandom.x);
}

vec2 hash2() {
    return fract(sin(vec2(seed+=0.1,seed+=0.1)) * magicRandom.xy);
}

vec3 hash3() {
    return fract(sin(vec3(seed+=0.1,seed+=0.1,seed+=0.1)) * magicRandom);
}

//-----------------------------------------------------
// Intersection functions (by iq)
//-----------------------------------------------------

vec3 nSphere( in vec3 pos, in vec4 sph ) {
    return (pos-sph.xyz)/sph.w;
}

float iSphere( in vec3 ro, in vec3 rd, in vec4 sph ) {
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

vec3 nPlane( in vec3 ro, in vec4 obj ) {
    return obj.xyz;
}

float iPlane( in vec3 ro, in vec3 rd, in vec4 pla ) {
    return (-pla.w - dot(pla.xyz,ro)) / dot( pla.xyz, rd );
}

//-----------------------------------------------------
// scene
//-----------------------------------------------------

vec3 cosWeightedRandomHemisphereDirection( const vec3 n ) {
  	vec2 r = hash2();
    
	vec3  uu = normalize( cross( n, vec3(0.0,1.0,1.0) ) );
	vec3  vv = cross( uu, n );
	
	float ra = sqrt(r.y);
	float rx = ra*cos(TWOPI * r.x); 
	float ry = ra*sin(TWOPI * r.x);
	float rz = sqrt( 1.0-r.y );
	vec3  rr = vec3( rx*uu + ry*vv + rz*n );
    
    return normalize( rr );
}

vec3 randomSphereDirection() {
    vec2 r = hash2() * TWOPI;
	vec3 dr=vec3(sin(r.x)*vec2(sin(r.y),cos(r.y)),cos(r.x));
	return dr;
}

vec3 randomHemisphereDirection( const vec3 n ) {
	vec3 dr = randomSphereDirection();
	return dot(dr,n) * dr;
}

//-----------------------------------------------------
// light
//-----------------------------------------------------

vec4 lightSphere;

void initLightSphere( float time ) {
	lightSphere = vec4( 3.0+2.*sin(time),2.8+2.*sin(time*0.9),3.0+4.*cos(time*0.7), .5 );
}

vec3 sampleLight( const in vec3 ro ) {
    vec3 n = randomSphereDirection() * lightSphere.w;
    return lightSphere.xyz + n;
}

//-----------------------------------------------------
// scene
//-----------------------------------------------------
void update(const float t, const float material, const vec3 normal, inout vec2 res, inout vec3 newNormal)
{
	if( t > eps && t < res.x ) 
	{ 
		res = vec2( t, material); 
		newNormal = normal; 
	}
}

vec2 intersect( in vec3 ro, in vec3 rd, inout vec3 normal ) {
	vec2 res = vec2( 1e20, -1.0 );
    float t;
	
	t = iPlane( ro, rd, vec4( 0.0, 1.0, 0.0,0.0 ) ); update(t, 1., vec3( 0., 1., 0.), res, normal);
	t = iPlane( ro, rd, vec4( 0.0, 0.0,-1.0,8.0 ) ); update(t, 5., vec3( 0., 0.,-1.), res, normal);
    t = iPlane( ro, rd, vec4( 1.0, 0.0, 0.0,0.0 ) ); update(t, 2., vec3( 1., 0., 0.), res, normal);
	
#ifdef FULLBOX
    t = iPlane( ro, rd, vec4( 0.0,-1.0, 0.0,5.49) ); update(t, 1., vec3( 0., -1., 0.), res, normal);
    t = iPlane( ro, rd, vec4(-1.0, 0.0, 0.0,5.59) ); update(t, 3., vec3(-1.,  0., 0.), res, normal);
#endif

	t = iSphere( ro, rd, SPHERE1 ); update(t, 5., nSphere( ro+t*rd, SPHERE1 ), res, normal);
    t = iSphere( ro, rd, SPHERE2 ); update(t, 6., nSphere( ro+t*rd, SPHERE2 ), res, normal); 
    t = iSphere( ro, rd, SPHERE3 ); update(t, 1., nSphere( ro+t*rd, SPHERE3 ), res, normal);  
    t = iSphere( ro, rd, lightSphere ); update(t, 0., nSphere( ro+t*rd, lightSphere ), res, normal);  
					  
    return res;					  
}

bool intersectShadow( in vec3 ro, in vec3 rd, in float dist ) {
    float t;
	
	t = iSphere( ro, rd, SPHERE1 );  if( t>eps && t<dist ) { return true; }
    t = iSphere( ro, rd, SPHERE2 );  if( t>eps && t<dist ) { return true; }
    t = iSphere( ro, rd, SPHERE3 );  if( t>eps && t<dist ) { return true; }

    return false; // optimisation: planes don't cast shadows in this scene
}

//-----------------------------------------------------
// materials
//-----------------------------------------------------

vec3 matColor( const in float mat ) {
	vec3 nor = vec3(0.4, 0.95, 0.9);
	
	if( mat<3.5 ) nor = REDCOLOR;
    if( mat<2.5 ) nor = GREENCOLOR;
	if( mat<1.5 ) nor = WHITECOLOR;
	if( mat<0.5 ) nor = LIGHTCOLOR;
					  
    return nor;					  
}

bool matIsRefractive( const in float mat ) {
    return mat > 5.5;
}

bool matIsSpecular( const in float mat ) {
    return mat > 4.5;
}

bool matIsLight( const in float mat ) {
    return mat < 0.5;
}

//-----------------------------------------------------
// brdf
//-----------------------------------------------------

vec3 getBRDFRay( in vec3 n, const in vec3 rd, const in float m, inout bool specularBounce ) {
    specularBounce = false;
    
    vec3 r = cosWeightedRandomHemisphereDirection( n );
    if(  !matIsSpecular( m ) ) {
        return r;
    } else {
        specularBounce = true;
        
		if(matIsRefractive(m))
		{
			float n1, n2, ndotr = dot(rd,n);
        
			if( ndotr > 0. ) {
				n1 = 1./1.5; n2 = 1.;
				n = -n;
			} else {
				n2 = 1./1.5; n1 = 1.;
			}
					
			float r0 = (n1-n2)/(n1+n2); r0 *= r0;
			float fresnel = r0 + (1.-r0) * pow(1.0-abs(ndotr),5.);
        
			vec3 ref;
			
			if( hash1() < fresnel ) {
				ref = reflect( rd, n );
			} else {
				ref = refract( rd, n, n2/n1 );
			}
        
			return ref; // normalize( ref + 0.1 * r );
		}
		return reflect( rd, n );
	}
}

//-----------------------------------------------------
// eyepath
//-----------------------------------------------------

vec3 traceEyePath( in vec3 ro, in vec3 rd, const in bool directLightSampling ) {
    vec3 tcol = vec3(0.);
    vec3 fcol  = vec3(1.);
    
    bool specularBounce = true;
    
    for( int j=0; j<EYEPATHLENGTH; ++j ) {
        vec3 normal;
        
        vec2 res = intersect( ro, rd, normal );
        if( res.y < -0.5 ) {
            return tcol;
        }
        
        if( matIsLight( res.y ) ) {
            if( directLightSampling ) {
            	if( specularBounce ) tcol += fcol*LIGHTCOLOR;
            } else {
                tcol += fcol*LIGHTCOLOR;
            }
         //   basecol = vec3(0.);	// the light has no diffuse component, therefore we can return col
            return tcol;
        }
        
        ro = ro + res.x * rd;
        rd = getBRDFRay( normal, rd, res.y, specularBounce );
        
        fcol *= matColor( res.y );

        vec3 ld = sampleLight( ro ) - ro;
        
        if( directLightSampling ) {
			vec3 nld = normalize(ld);
            if( !specularBounce && j < EYEPATHLENGTH-1 && !intersectShadow( ro, nld, length(ld)) ) {

                float cos_a_max = sqrt(1. - clamp(lightSphere.w * lightSphere.w / dot(lightSphere.xyz-ro, lightSphere.xyz-ro), 0., 1.));
                float weight = 2. * (1. - cos_a_max);

                tcol += (fcol * LIGHTCOLOR) * (weight * clamp(dot( nld, normal ), 0., 1.));
            }
        }
    }    
    return tcol;
}

//-----------------------------------------------------
// main
//-----------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 q = fragCoord.xy / iResolution.xy;
    
#ifdef SHOWSPLITLINE
	float splitCoord = (iMouse.x == 0.0) ? iResolution.x/2. + iResolution.x*cos(iGlobalTime*.5) : iMouse.x;
    bool directLightSampling = fragCoord.x < splitCoord;
#else
    bool directLightSampling = true;
#endif
    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------

    vec2 p = -1.0 + 2.0 * (fragCoord.xy) / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;

#ifdef ANIMATENOISE
    seed = p.x + p.y * 3.43121412313 + fract(1.12345314312*iGlobalTime);
#else
    seed = p.x + p.y * 3.43121412313;
#endif
    
    vec3 ro = vec3(2.78, 2.73, -8.00);
    vec3 ta = vec3(2.78, 2.73,  0.00);
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));

    //-----------------------------------------------------
    // render
    //-----------------------------------------------------

    vec3 col = vec3(0.0);
    vec3 tot = vec3(0.0);
    vec3 uvw = vec3(0.0);
    
    for( int a=0; a<SAMPLES; a++ ) {

        vec2 rpof = 4.*(hash2()-vec2(0.5)) / iResolution.xy;
	    vec3 rd = normalize( (p.x+rpof.x)*uu + (p.y+rpof.y)*vv + 3.0*ww );
        
#ifdef DOF
	    vec3 fp = ro + rd * 12.0;
   		vec3 rof = ro + (uu*(hash1()-0.5) + vv*(hash1()-0.5))*0.125;
    	rd = normalize( fp - rof );
#else
        vec3 rof = ro;
#endif        
        
#ifdef MOTIONBLUR
        initLightSphere( iGlobalTime + hash1() / MOTIONBLURFPS );
#else
        initLightSphere( iGlobalTime );        
#endif
        
        col = traceEyePath( rof, rd, directLightSampling );

        tot += col;
        
        seed = mod( seed*1.1234567893490423, 13. );
    }
    
    tot /= float(SAMPLES);
    
#ifdef SHOWSPLITLINE
	if (abs(fragCoord.x - splitCoord) < 1.0) {
		tot.x = 1.0;
	}
#endif
    
	tot = pow( clamp(tot,0.0,1.0), vec3(0.45) );

    fragColor = vec4( tot, 1.0 );
}

void main()
{
	mainImage(gl_FragColor, gl_FragCoord.xy);
}