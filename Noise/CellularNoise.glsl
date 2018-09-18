//idea from http://thebookofshaders.com
#version 110

vec2 random2( vec2 p ) {
	return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

uniform vec2 iResolution;
uniform float iGlobalTime;
uniform vec3 iMouse;

float time = iGlobalTime;

void main() {
	//coordinates in range [0,1]
	vec2 coord = gl_FragCoord.xy/iResolution;

	// Scale 
	coord *= 15.0;

	// Tile the space
	vec2 cell = floor(coord);
	vec2 coordFract = fract(coord);
	
	float minDist = 1e4;
	for (int y= -1; y <= 1; ++y) 
	{
		for (int x= -1; x <= 1; ++x) 
		{
			// delta place in the grid
			vec2 delta = vec2(float(x),float(y));
			vec2 point = random2(cell + delta); //one random point per cell
			
			//point = 0.5 + 0.5 * sin(time + time * point); // animate each point
			
			float dist = distance(coordFract, delta + point);
			minDist = min(minDist, dist);
		}
	}
	
	vec3 color = vec3(minDist);

	gl_FragColor = vec4(color, 1.0);
}
