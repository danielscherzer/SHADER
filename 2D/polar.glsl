#version 330

const float PI = 3.14159265359;
const float TWOPI = 2 * PI;
const float EPSILON = 10e-4;

uniform vec2 u_resolution;
uniform float iGlobalTime;

out vec3 fragColor;
void main()
{
	vec2 uv = gl_FragCoord.xy/u_resolution.xy;
	vec3 color = vec3(0.0);
	
	// range [-1..1]²
	uv = vec2(1) - 2 * uv;
	//aspect correction
	uv.x *= u_resolution.x / u_resolution.y;
	
	//cartesian to polar coordinates
	float r = length(uv); // radius of current pixel
	float a = atan(uv.y, uv.x) + PI; //angel of current pixel [0..2*PI] 
	
	float f = a / TWOPI;
//	f = cos(4 * a); // step 2 
//	f = abs(cos(4 * a)); // step 3 
//	f = abs(cos(2.5 * a)) * 0.6 + 0.3; // step 6 
//	f = abs(cos(4 * a) * sin(3 * a)) * 0.8 + 0.1; // step 7 
//	f = smoothstep(-0.5, 1, cos(20 * a)) * 0.15 + 0.6; // step 8 

	//sides
	int N = 6;
	float fact = TWOPI / N;
//	f = a / fact; // step 9 
//	f = cos(a - floor(0.5 + a / fact) * fact) * r; // step 10 

	color = vec3(r);
//	color = vec3(f); // step 1 
//	color = vec3(step(f, r)); // step 4 
//	color = vec3(smoothstep(f, f + 0.01, r)); // step 5 
//	color = vec3(smoothstep(0.4, 0.401, f));// step 9 
	
	fragColor = color;
}
