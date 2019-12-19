// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

uniform vec3 iMouse;
uniform vec2 u_resolution;
uniform float iGlobalTime;

float iTime = iGlobalTime;

//#define HIGH_QUALITY_NOISE

// port from http://glslsandbox.com/e#1802.0 with some modifications
//--------------
// Posted by las
// http://www.pouet.net/topic.php?which=7920&page=29&x=14&y=9

#define SCATTERING

#define pi 3.14159265
#define R(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)

//original noise
float pn(vec3 p) {
   vec3 i = floor(p);
   vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
   vec3 f = cos((p-i)*pi)*(-.5) + .5;
   a = mix(sin(cos(a)*a), sin(cos(1.+a)*(1.+a)), f.x);
   a.xy = mix(a.xz, a.yw, f.y);
   return mix(a.x, a.y, f.z);
}

float fpn(vec3 p) {
   return pn(p*.06125)*.5 + pn(p*.125)*.25 + pn(p*.25)*.125;
}

//vec3 n1 = vec3(1.000,0.000,0.000);
//vec3 n2 = vec3(0.000,1.000,0.000);
//vec3 n3 = vec3(0.000,0.000,1.000);
vec3 n4 = vec3(0.577,0.577,0.577);
vec3 n5 = vec3(-0.577,0.577,0.577);
vec3 n6 = vec3(0.577,-0.577,0.577);
vec3 n7 = vec3(0.577,0.577,-0.577);
vec3 n8 = vec3(0.000,0.357,0.934);
vec3 n9 = vec3(0.000,-0.357,0.934);
vec3 n10 = vec3(0.934,0.000,0.357);
vec3 n11 = vec3(-0.934,0.000,0.357);
vec3 n12 = vec3(0.357,0.934,0.000);
vec3 n13 = vec3(-0.357,0.934,0.000);
vec3 n14 = vec3(0.000,0.851,0.526);
vec3 n15 = vec3(0.000,-0.851,0.526);
vec3 n16 = vec3(0.526,0.000,0.851);
vec3 n17 = vec3(-0.526,0.000,0.851);
vec3 n18 = vec3(0.851,0.526,0.000);
vec3 n19 = vec3(-0.851,0.526,0.000);

float spikeball(vec3 p) {
   vec3 q=p;
   p = normalize(p);
   vec4 b = max(max(max(
      abs(vec4(dot(p,n16), dot(p,n17),dot(p, n18), dot(p,n19))),
      abs(vec4(dot(p,n12), dot(p,n13), dot(p, n14), dot(p,n15)))),
      abs(vec4(dot(p,n8), dot(p,n9), dot(p, n10), dot(p,n11)))),
      abs(vec4(dot(p,n4), dot(p,n5), dot(p, n6), dot(p,n7))));
   b.xy = max(b.xy, b.zw);
   b.x = pow(max(b.x, b.y), 140.);
   return length(q)-2.5*pow(1.5,b.x*(1.-mix(.3, 1., sin(iTime*2.)*.5+.5)*b.x));
}

float f(vec3 p) {
   p.z += 6.;
   R(p.xy, iTime);
   R(p.xz, iTime);
   return (spikeball(p) + fpn(p*50.+iTime*15.) * 0.45) * 0.5;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{  
   // pos: position on the ray
   // dir: direction of the ray
   vec3 pos = vec3(0.,0.,2.);
   vec3 dir = vec3((gl_FragCoord.xy/(0.5*u_resolution.xy)-1.)*vec2(u_resolution.x/u_resolution.y,1.0), 0.) - pos;
   dir = normalize(dir); 
   
   // ld, td: local, total density 
   // w: weighting factor
   float ld=0., td=0.;
   float w=0.;
   
   // total color
   vec3 tc = vec3(0.);
   
   // i: 0 <= i <= 1.
   // r: length of the ray
   // l: distance function
   float r=0., l=0., b=0.;

   // rm loop
   for (float i=0.; (i<1.); i+=1./64.) {
	   if(!((i<1.) && (l>=0.001*r) && (r < 50.)&& (td < .95)))
		   break;
      // evaluate distance function
      l = f(pos);
      
      // check whether we are close enough (step)
      // compute local density and weighting factor 
      const float h = .05;
      ld = (h - l) * step(l, h);
      w = (1. - td) * ld;   
     
      // accumulate color and density
      tc += w; 
      td += w;
       
      td += 1./200.;
      
      // enforce minimum stepsize
      l = max(l, 0.03);
      
      // step forward
      pos += l * dir;
      r += l;
   }  
    
   #ifdef SCATTERING
   // simple scattering approximation
   tc *= 1. / exp( ld * 0.4 ) * 1.25;
   #endif
      
   // fragColor = vec4(tc, 1.0);
   fragColor = vec4(tc.x+td*2., ld*3., 0, 0);
}

void main()
{
	mainImage(gl_FragColor, gl_FragCoord.xy);
}