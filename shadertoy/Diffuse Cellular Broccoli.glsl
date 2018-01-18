uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;
varying vec2 uv;
		
// added color.. o.O 
// Andrew Caudwell 2014
// @acaudwell

#define MAX_RAY_STEPS 100
#define PI 3.14159265359

#define DEGREES_TO_RADIANS 0.017453292

#define IFS_ITERATIONS 12

struct IFS {
    vec3  offset;
    float scale;
    vec3  axis;
    float angle;
    mat4  transform;
};

IFS IFS_constructor(vec3 offset, vec3 axis, float angle, float scale) {
	IFS ifs;
	ifs.offset = offset;
	ifs.axis   = axis;
	ifs.angle  = angle;
	ifs.scale  = scale;
	
	return ifs;
}

mat4 calc_transform(inout IFS ifs) {
    float angle = ifs.angle * DEGREES_TO_RADIANS;

    float c = cos(angle);
    float s = sin(angle);

    vec3 t = (1.0-c) * ifs.axis;

    return mat4(
        vec4(c + t.x * ifs.axis.x, t.y * ifs.axis.x - s * ifs.axis.z, t.z * ifs.axis.x + s * ifs.axis.y, 0.0) * ifs.scale,
        vec4(t.x * ifs.axis.y + s * ifs.axis.z, (c + t.y * ifs.axis.y),          t.z * ifs.axis.y - s * ifs.axis.x, 0.0) * ifs.scale,
        vec4(t.x * ifs.axis.z - s * ifs.axis.y, t.y * ifs.axis.z + s * ifs.axis.x, c + t.z * ifs.axis.z, 0.0) * ifs.scale,
        vec4(ifs.offset, 1.0)
    );
}

#define t iGlobalTime*0.6

int stage_no  = int(fract(t/float(IFS_ITERATIONS*2)) * float(IFS_ITERATIONS*2));
float stage_t = smoothstep(0.0, 1.0, fract(t));

IFS ifs_N;
IFS ifs_lerp;

void InitIFS() {
	
    if(stage_no >= IFS_ITERATIONS) {
        stage_no = IFS_ITERATIONS-(stage_no-IFS_ITERATIONS)-1;
        stage_t  = 1.0-stage_t;
    }
	
    // IFS to visualize
    ifs_N = IFS_constructor(vec3(-1.5), normalize(vec3(-1.0)), -36.0, 1.5);
	
	ifs_lerp.axis   = ifs_N.axis;
	ifs_lerp.angle  = ifs_N.angle;

	// interpolate scale and position offset
	ifs_lerp.offset = ifs_N.offset * stage_t;
	ifs_lerp.scale  = 1.0 + (ifs_N.scale-1.0) * stage_t;
	
	// left mouse button disables interpolation
	if(iMouse.z>0.0) {
		ifs_lerp = ifs_N;
	}
	
    ifs_N.transform    = calc_transform(ifs_N);
    ifs_lerp.transform = calc_transform(ifs_lerp);
}

// The definitive Fractal Forums thread about this class of fractals:
// http://www.fractalforums.com/ifs-iterated-function-systems/kaleidoscopic-%28escape-time-ifs%29/

float scene(vec3 p) {

	IFS ifs = ifs_N;
	
	float scale = 1.0;
				
	for(int i=0;i<IFS_ITERATIONS;i++) {

		if(i==stage_no) ifs = ifs_lerp;
		else if(i>stage_no) break;
			
		// mirror on 2 axis to get a tree shape
		p.xy = abs(p.xy);
	
		// apply transform
		p = (ifs.transform * vec4(p, 1.0)).xyz;
		
		scale *= ifs.scale;
	}
		
	// divide by scale preserve correct distance
	return (length(p)-2.0) / scale;
}

vec3 normal(vec3 p) {

    vec2 o = vec2(0.001,0.0);

	float d = scene(p);
	
    float d1 = d-scene(p+o.xyy);
    float d2 = d-scene(p+o.yxy);
    float d3 = d-scene(p+o.yyx);

    return normalize(vec3(d1,d2,d3));
}

float AO(vec3 p, vec3 normal) {

    float a = 1.0;

	float c = 0.0;
    float s = 0.25;

    for(int i=0; i<3; i++) {
	    c += s;
        a *= 1.0-max(0.0, (c -scene(p + normal*c)) * s / c);
    }

    return clamp(a,0.0,1.0);
}

float map( in vec3 p )
{
	float e = 1.0;//2.0*texture2D( iChannel0, vec2(0.01,0.25) ).x;
    return min( e +  length(p) - 1.0, p.y+1.0 );
}

vec3 calcNormal( in vec3 p )
{

	vec3 e = vec3(0.001,0.0,0.0);
	return normalize( vec3(map(p+e.xyy) - map(p-e.xyy),
						   map(p+e.yxy) - map(p-e.yxy),
						   map(p+e.yyx) - map(p-e.yyx) ) );
						   
}

void main(void) {
	
	InitIFS();
	
    vec2 uv = (gl_FragCoord.xy / iResolution.xy) * 2.0 - 1.0;
	
    vec3 dir = normalize(vec3(uv.x, uv.y * (iResolution.y/iResolution.x), 1.0));

    vec3 p = vec3(0.0,0.0,-4.1);
		
	float d = 0.0;

	for(int i=0; i<MAX_RAY_STEPS; i++) {
        d = scene(p);		
		
		p += d * dir;
		if(d<0.001) break;
    }
	
	vec3 c = vec3(0.0);
	
	if(d<0.001) {
		vec3 l = vec3(-3.0, 3.0, 3.0);

		vec3 n = -normal(p-dir*0.001);
		
		c = vec3(0.4);

		c += 1.5 * (max(0.0, dot(n, normalize(l-p)))/length(l-p));

		c *= AO(p, 0.5*(n+normalize(n+l)));
		
		// c *= calcNormal(dir);
	}
	
    gl_FragColor = vec4(c,1.0);
}