uniform vec2 iResolution;
uniform float iGlobalTime;

const float range = 12.0; 					// input value range [-div/2..div/2]
const float pi = 3.14159;
    
void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv -= 0.5;									// (0,0) is center on screen

	float aspect = iResolution.y / iResolution.x;

    vec2 bigUV = vec2( range, range * aspect ) * uv;
    
    vec2 S;
	S.x = (bigUV.x + bigUV.y)*(bigUV.x - bigUV.y)*0.5;	// "velocity potential"
    S.y = bigUV.x * bigUV.y;					// stream function
	S.x += iGlobalTime * 3.0;					// animate stream
    
    vec2 sxy = abs( sin(pi * S) );
    float a = sxy.x * sxy.y;					// combine sine waves using product
    
    float b = 4.0 * range / iResolution.x;		// blur over 2.4 pixels
	a = smoothstep( 0.8 - b, 0.8 + b, a );		// threshold
    
    float c = sqrt( a );						// correct for gamma
	gl_FragColor = vec4(c, c, c, 1.0);
}