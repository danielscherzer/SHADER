#version 330

// based on http://iquilezles.org/www/articles/distancefractals/distancefractals.htm
const float EPSILON = 10e-4;
const float BIG_NUMBER = 1e3;

uniform vec2 u_resolution;
uniform float iGlobalTime;
uniform vec3 iMouse;
	
vec2 complexMul(vec2 a, vec2 b)
{
	return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 mandelBrotStep(vec2 zn, vec2 c)
{
	// Complex Z_(n+1) -> Z_n² + c
	return complexMul(zn, zn) + c;
}

vec2 dMandelBrotStep(vec2 zn, vec2 dzn)
{
	// Complex Z_(n+1) -> 2 * Z_n * Z_n' + 1
	return 2.0 * complexMul(zn, dzn) + vec2(1.0, 0.0);
}

//create uv to be in the range [0..1]² and then correct aspect ratio
vec2 normCoord(vec2 rasterCoord)
{
	vec2 uv = rasterCoord / u_resolution;
	uv.x *= u_resolution.x / u_resolution.y;
	return uv;
}

// cosine based palette
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
	return a + b * cos( 6.28318 * (c * t + d) );
}

out vec3 color;
void main()
{
	vec2 uv = normCoord(gl_FragCoord.xy);
	
	uv = -1 + 2 * uv;

//	vec2 mouse = normCoord(iMouse.xy);
//	mouse = 2 * mouse - vec2(1);
//	uv -= iMouse.z * mouse;

	// animation
	float tz = 0.5 - 0.5 * cos(0.225 * iGlobalTime);
	float zoo = pow( 0.5, 13.0 * tz );
	vec2 c = vec2(-0.05,.6805) + uv * zoo;

	vec2 z = vec2(0.0);
	vec2 dz = vec2(0.0);
	bool converged = true;
	for(int i = 0; i < 300; ++i)
	{
		dz = dMandelBrotStep(z, dz);
		z = mandelBrotStep(z, c);
		if(dot(z,z) > BIG_NUMBER)
		{
			//no convergence here
			converged = false;
			break;
		}
	}

	// distance
	// d(c) = |Z|·log|Z|/|Z'|
	float d = converged ? 0.0 : 0.5 * sqrt(dot(z, z) / dot(dz,dz)) * log(dot(z, z));
	
	// do some soft coloring based on distance
	d = clamp( pow(4.0*d / zoo,0.2), 0.0, 1.0 );

	vec3 freq = vec3(1.0);
//	freq = vec3(4.0, 7.0, 11.0);
	color = vec3( palette(d, vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5), freq, vec3(0.0, 0.1, 0.2)));
}

