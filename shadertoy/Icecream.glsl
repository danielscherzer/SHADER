uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;
varying vec2 uv;
		

#define TIME_MULT 1.

#define MAXSTEPS 300
#define MINSTEP 0.0005
#define MAXDIST 100.0
#define NORMALSTEP MINSTEP

float t;

float distfield( vec3 pos )
{
	float R = 1.+cos(pos.z*pos.z*15.+2.*t)*0.01 + sin((sin(pos.x*2.+t*0.2)-pos.z+pos.y)*7.+cos(pos.z*pos.z*15.+2.*t)*10.)*0.002;
	return length(pos)-R;
}

float trace( vec3 from, vec3 ray, inout vec3 n )
{
	n = vec3(0,0,1);
	float dist = from.z / -ray.z;
	if (dist < 0.) return MAXDIST;
	return dist;
}

float raymarch( vec3 from, vec3 ray, float maxdist )
{
    float dist = 0.0, d;
    vec3 curpos = from;

    for (int j=0; j<MAXSTEPS; ++j)
    {
        d = distfield(curpos);
        if (dist > maxdist) break;
        if (d < 0.0) break;
        d = max(d, MINSTEP);
        dist += d;
        curpos += ray*d;
    }
    if (d >= 0.0) dist = MAXDIST;

    return dist;
}

vec3 distfield_normal( vec3 p )
{
	// This is taken from "GENERATORS REDUX" by Kali
	
    vec3 e = vec3(0.0, NORMALSTEP, 0.0);
    return normalize(vec3(
        distfield(p+e.yxx)-distfield(p-e.yxx),
        distfield(p+e.xyx)-distfield(p-e.xyx),
        distfield(p+e.xxy)-distfield(p-e.xxy)
        ));	
}

vec3 water_texture( vec3 pos )
{
	float w = 0.05 / (length(pos)*3.+1.);
	float gx = sin(20.*pos.x + cos(pos.y)*2. + t);
	float gy = cos(pos.y*5.+2.*t + sin(pos.x+1.*t))+ cos((pos.x-pos.y+sin(pos.x+.2*t)*0.5)*(1.+.3*cos(.2*t+3.*pos.x))*25.)*0.2;
	return normalize( vec3(gx*gy*w, (gy+gy)*w*.5, 1) );
}

vec3 trace_col( vec3 ray, vec3 pos )
{
	const vec3 diffuse_color = vec3(1, .9, .8)*1.2;
	const vec3 unnorm_light_dir = vec3(-1,3,5);
	
    vec3 col = vec3(1,1,1), n, isec, diff_col = diffuse_color;
	col = mix(col, vec3(0,0,1), ray.z);

	float dist1 = trace(pos, ray, n);
    float dist2 = raymarch(pos, ray, dist1);
	bool refl = false, hit = false;
	
	float dist = min(dist1, dist2);
	
	if (dist < MAXDIST)
	{
		isec = dist*ray+pos;
		
		if (dist2 < dist1)
		{
			n = distfield_normal( isec );
			hit = true;
		}
		else
		{
			pos = isec;
			n = water_texture( pos );
			diff_col = vec3(.3,.3,.5);
			ray = reflect( ray, n );
			dist2 = raymarch(pos, ray, MAXDIST);
			if (dist2 < MAXDIST)
			{
				isec = dist2*ray+pos;
				n = distfield_normal( isec );
				dist = dist + dist2;
				refl = true;
				hit = true;
			}
			else
			{
				diff_col = mix(diff_col,vec3(.9,.9,1),ray.z);
			}
		}
		
		float l = dot(n, normalize(unnorm_light_dir));
		col = diff_col * max(l,0.0);
		col = mix(vec3(1,1,1), col, exp(-dist*.1));
		if (hit) col *= 1.0-exp(-isec.z*20.);
		if (refl) col = mix(col, vec3(1,1,1), 0.15);
	}
		
    return col;
}


void main(void)
{
	float aspect = iResolution.x / iResolution.y;
	
	const float view_plane_dist = 1.6;
	const vec3 camera_pos = vec3(0,0,-3);
	
	vec3 ray = vec3(
		((gl_FragCoord[0] / iResolution.x)*2.0-1.0)*aspect,
		((gl_FragCoord[1] / iResolution.y)*2.0-1.0),
		view_plane_dist );

	float h = iMouse.x/iResolution.x * 8.0 + 1.1;
	float p = -(iMouse.y/iResolution.y + 1.0) * 2.0;
	
	float c = cos(h), s = sin(h);
	t = iGlobalTime  * TIME_MULT;

	mat4 hrot = mat4(c, -s, 0, 0, s,c,0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
	
	c = cos(p);
	s = sin(p);
	
	mat4 prot = mat4(1,0,0, 0, 0, c,  s, 0, 0, -s, c, 0, 0,0,0,1);


	vec4 r = hrot * prot * vec4(ray,1);
	ray = vec3(r.x,r.y,r.z);
	vec4 cp = hrot * prot * vec4(camera_pos,1);

	vec3 pos = vec3(cp.x,cp.y,cp.z);
	ray = normalize(ray);

	gl_FragColor = vec4(trace_col(ray, pos),1.);
}