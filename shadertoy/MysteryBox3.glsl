uniform vec2 iMouse;
uniform vec2 u_resolution;
uniform float iGlobalTime;
varying vec2 uv;
		
// reference:
// https://www.shadertoy.com/view/Xds3zN
// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

vec3 opRep( vec3 p )
{
	vec3 c = vec3( 2.0, 1.0, 1.0 );
	return mod(p,c)-0.5*c;
}

vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

float opS( float d1, float d2 )
{
	return max(-d1,d2);
}

vec3 opTwist( vec3 p )
{
    float  c = cos(00.1*p.z + iGlobalTime*0.2);
    float  s = sin(00.1*p.z + iGlobalTime*0.2);
    mat2   m = mat2(c,-s,s,c);
    return vec3(m*p.xy,p.z);
}


float sdBox( vec3 p, vec3 b )
{
	vec3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float map( in vec3 pos )
{
	float box = sdBox( opRep( opTwist(pos-vec3(0.0, 0.0, 0.0)) ), vec3(0.29, 0.09, 0.29) );
	float innerbox = sdBox( opRep( opTwist(pos-vec3( 0.0, 0.0, 0.0)) ), vec3(0.17, 0.2, 0.17) );
	
	float logo = opS( innerbox, box );
	
	return logo;
}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
		map(pos+eps.xyy) - map(pos-eps.xyy),
		map(pos+eps.yxy) - map(pos-eps.yxy),
		map(pos+eps.yyx) - map(pos-eps.yyx));
	return normalize(nor);
}


vec2 castRay( in vec3 ro, in vec3 rd, in float maxd )
{
	float precis = 0.001;
	float h=precis*2.0;
	float t = 0.0;
	float m = -1.0;
	for( int i=0; i<60; i++ )
	{
		if( abs(h)<precis||t>maxd ) continue;//break;
		t += h;
		h = map( ro+rd*t );
		m = 0.0;
	}

	if( t>maxd ) m=-1.0;
	return vec2( t, m );
}


vec3 render( in vec3 ro, in vec3 rd )
{ 
    	vec3 col = vec3(0.0);
    	vec2 res = castRay(ro,rd,20.0);
    	float t = res.x;
    	float m = res.y;

    	vec3 pos = ro + t*rd;
    	vec3 nor = calcNormal( pos );

    	col = vec3(0.6) + 0.4*sin( vec3(0.05,0.08,0.10)*(m-1.0) );

		vec3 lig = normalize( vec3(0.0, 1.0, 0.0) );
    	float dif = clamp( dot( nor, lig ), 0.0, 1.0 );

    	col = col*dif;

    	col *= exp( -0.01*t*t );


    	return vec3( clamp(col,0.0,1.0) );
}


void main( void )
{

	vec2 q = gl_FragCoord.xy/u_resolution.xy;
	vec2 p = -1.0+2.0*q;
	p.x *= u_resolution.x/u_resolution.y;
	
	// camera 
	vec3 ro = vec3( 1.0*cos(0.2*iGlobalTime), 0.3, 1.0*sin(0.1*iGlobalTime) );
	vec3 ta = vec3( 0.0, 0.2, 0.0 );
    
	// camera tx
	vec3 cw = normalize( ta-ro );
	vec3 cp = vec3( 0.0, 1.0, 0.0 );
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
	vec3 rd = normalize( p.x*cu + p.y*cv + 1.5*cw );

  
	vec3 col = render( ro, rd );

	col = sqrt(sqrt( col ) );
	
	gl_FragColor = vec4(col,1.0);
}
