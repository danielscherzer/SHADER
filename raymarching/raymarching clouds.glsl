#version 330

#include "../libs/camera.glsl" 
#include "../libs/rayIntersections.glsl" 
// #include "../libs/noise3D.glsl" //uncomment for simplex noise: slower but more "fractal"

uniform float iGlobalTime;
uniform vec2 iResolution;

float time = iGlobalTime + 0.7;

// adapted from https://www.shadertoy.com/view/4sfGzS 

vec3 sundir = normalize( vec3(sin(time), 0.0, cos(time)) );

const int STEPS = 200;
const int OCTAVES = 3;

float hash(vec3 p)
{
    p  = fract( p*0.3183099 + .1 );
	p *= 17.0;
    return fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

float noise( in vec3 x )
{
	x *= 2;
#ifdef noise3D_glsl
	return snoise(x * 0.25); //enable: slower but more "fractal"
#endif
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    return mix(mix(mix( hash(p+vec3(0,0,0)), 
                        hash(p+vec3(1,0,0)),f.x),
                   mix( hash(p+vec3(0,1,0)), 
                        hash(p+vec3(1,1,0)),f.x),f.y),
               mix(mix( hash(p+vec3(0,0,1)), 
                        hash(p+vec3(1,0,1)),f.x),
                   mix( hash(p+vec3(0,1,1)), 
                        hash(p+vec3(1,1,1)),f.x),f.y),f.z);
}

float fbm(vec3 p, const int octaves )
{
	float f = 0.0;
	float weight = 0.5;
	for(int i = 0; i < octaves; ++i)
	{
		f += weight * noise( p );
		weight *= 0.5;
		p *= 2.0;
	}
	return f;
}

float densityFunc(const vec3 p)
{
	vec3 q = p;// + vec3(0.0, 0.10, 1.0) * time; //clouds move
	float f = fbm(q, OCTAVES);
	return clamp( 2 * f - p.y - 1, 0.0, 1.0 );
}

vec3 lighting(const vec3 pos, const float cloudDensity
			, const vec3 backgroundColor, const float pathLength )
{
	float densityLightDir = densityFunc(pos + 0.3 * sundir); // sample in light dir
	float gradientLightDir = clamp(cloudDensity - densityLightDir, 0.0, 1.0);
			
    vec3 litColor = vec3(0.91, 0.98, 1.0) + vec3(1.0, 0.6, 0.3) * 2.0 * gradientLightDir;        
	vec3 cloudAlbedo = mix( vec3(1.0, 0.95, 0.8), vec3(0.25, 0.3, 0.35), cloudDensity );

	const float extinction = 0.0003;
	float transmittance = exp( -extinction * pathLength );
    return mix(backgroundColor, cloudAlbedo * litColor, transmittance );
}

vec4 raymarchClouds(const Ray ray, const vec3 backgroundColor )
{
	vec4 sum = vec4(0.0);
	float t = 0.0;
	for(int i = 0; i < STEPS; ++i)
	{
		vec3 pos = ray.origin + t * ray.dir;
		if( 0.99 < sum.a ) break; //break if opaque
		float cloudDensity = densityFunc( pos );
		if( 0.01 < cloudDensity ) // if not empty -> light and accumulate 
		{
			vec3 colorRGB = lighting( pos, cloudDensity, backgroundColor, t );
			float alpha = cloudDensity * 0.4;
			vec4 color = vec4(colorRGB * alpha, alpha);
			sum += color * ( 1.0 - sum.a ); //blend-in new color contribution
		}
		t += max( 0.05, 0.02 * t ); //step size at least 0.05, increase t with each step
	}
    return clamp( sum, 0.0, 1.0 );
}

vec3 render(const Ray ray)
{
    // background sky     
	float sun = clamp( dot( sundir, ray.dir ), 0.0, 1.0 );
	vec3 backgroundSky = vec3( 0.7, 0.79, 0.83 )
		- ray.dir.y * 0.2 * vec3( 1.0, 0.5, 1.0 )
		+ 0.2 * vec3( 1.0, 0.6, 0.1 ) * pow( sun, 8.0 );

    // clouds    
    vec4 res = raymarchClouds( ray, backgroundSky );
    vec3 col = backgroundSky * ( 1.0 - res.a ) + res.rgb; // blend clouds with sky
    
    // add sun glare    
	col += 0.2 * vec3( 1.0, 0.4, 0.2 ) * pow( sun, 3.0 );

    return col;
}

void main()
{
	vec3 camP = calcCameraPos();
	vec3 camDir = calcCameraRayDir(80.0, gl_FragCoord.xy, iResolution);

    vec3 color = render( Ray( camP, camDir ) );
    gl_FragColor = vec4(color, 1.0 );
}



