uniform float u_time;
uniform vec2 u_resolution;

#define F length(fract(q*=m*=.4-gl_FragColor.w++)-.5)

void main()
{
    vec3 q = vec3(.01 * gl_FragCoord.xy, 0.1 * u_time);
    
    mat3 m = mat3( -1, 2,-2,
                   -2, 1, 3,
                    3, 2, 1 );

    gl_FragColor = min(min(F,F),F)/m[2].xyzx;
}
