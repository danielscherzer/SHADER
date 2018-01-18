#version 330

#include "../libs/Noise2D.glsl"

uniform vec3 iMouse;
uniform float iGlobalTime;
uniform vec2 iResolution;

#define RAYMARCHSTEPS 550

//fractal Brownian motion
float fbm(vec2 coord) 
{
	int octaves = 5;
    float value = 0;
    float amplitude = 0.5;
	float lacunarity = 2;
	float gain = 0.3;
    vec2 shift = vec2(100);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), 
                    -sin(0.5), cos(0.5));
    for (int i = 0; i < octaves; ++i) {
        value += amplitude * snoise(coord) * 0.5;
        coord = rot * coord * lacunarity + shift;
        amplitude *= gain;
    }
    return value;
}
				  
float heightField( vec2 coord) 
{
	return fbm(coord * 0.35) * 4;
}

void main()
{
	vec2 q = gl_FragCoord.xy / iResolution.xy;
	vec2 p = 2 * q - 1;
	p.x *= iResolution.x / iResolution.y;
	
	vec2 pos = vec2( -0.5, iGlobalTime + 5.5);
	
	vec3 ro = vec3( pos.x, heightField(pos) + 0.25, pos.y);
	vec3 rd = vec3(p, 1);
	
	float dist;
	vec3 col = vec3(0.);
	vec3 intersection = vec3(9999.);
	
	// terrain - raymarch
	float t, h = 0.;
	const float dt=0.05;
	
	t = mod( ro.z, dt );
	
	for( int i=0; i<RAYMARCHSTEPS; i++) {
		if( h < intersection.y ) {
			t += dt;
			intersection = ro + rd*t;
			
			h = heightField( intersection.xz );
		}
	}
	if( h > intersection.y ) {	
		// calculate projected height of intersection and previous point
		float h1 = (h-ro.y)/(rd.z*t);
		vec3 prev =  ro + rd*(t-dt);
		float h2 = (heightField( prev.xz )-ro.y)/(rd.z*(t-dt));
				
		float dx1 = heightField( intersection.xz+vec2(0.001,0.0) ) - heightField( intersection.xz+vec2(-0.001, 0.0) );
		dx1 *= (1./0.002);
		float dx2 = heightField( prev.xz+vec2(0.001,0.0) ) - heightField( prev.xz+vec2(-0.001, 0.0) );
		dx2 *= (1./0.002);
		
		float dx = mix( dx1, dx2, clamp( (h1-p.y)/(h1-h2), 0., 1.));
		
		col = mix( vec3(0.8, 0.2, 0.2), vec3(0.1, 0, 0), 0.5 + 0.25 * dx);

	}
	
	gl_FragColor = vec4(col,1.0);
}