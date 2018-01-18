uniform vec3 iMouse;
uniform vec2 iResolution;
uniform float iGlobalTime;
varying vec2 uv;

const float PI = 3.14159265358979323846;

vec2 posRep( vec2 p, float c )
{
    return mod(p, c) - 0.5 * c;
}

float hitTunnel1(vec3 p)
{
    float tunnel1_p = 2.0;
    float tunnel1_w = tunnel1_p * 0.225;
    return length(posRep(p.xy, tunnel1_p)) - tunnel1_w;
}

float hitTunnel2(vec3 p)
{
	float tunnel2_p = 2.0;
    float tunnel2_w = tunnel2_p * 0.2125 + tunnel2_p * 0.0125 * cos(PI * p.y * 8.0) + tunnel2_p * 0.0125 * cos(PI * p.z * 8.0);
    return length(posRep(p.xy, tunnel2_p)) - tunnel2_w;
}

float hitHole1(vec3 p)
{
	float hole1_p = 1.0;
    float hole1_w = hole1_p * 0.5;
    return length(posRep(p.xz, hole1_p)) - hole1_w;
}

float hitHole2(vec3 p)
{
	float hole2_p = 0.25;
    float hole2_w = hole2_p * 0.375;
    return length(posRep(p.yz, hole2_p)) - hole2_w;
}

float hitHole3(vec3 p)
{
	float hole3_p = 0.5;
    float hole3_w = hole3_p * 0.25 + 0.125 * sin(PI * p.z * 2.0);
    return length(posRep(p.xy, hole3_p)) - hole3_w;
}

float hitTube(vec3 p)
{
    float tube_p = 0.5 + 0.075 * sin(PI * p.z);
    float tube_w = tube_p * 0.025 + 0.00125 * cos(PI * p.z * 128.0);
    return length(posRep(p.xy, tube_p)) - tube_w;
}

float hitBubble(vec3 p)
{
	float bubble_p = 0.05;
    float bubble_w = bubble_p * 0.5 + 0.025 * cos(PI * p.z * 2.0);
    return length(posRep(p.yz, bubble_p)) - bubble_w;
}

float draw_scene(vec3 p)
{
	float tunnel1 = hitTunnel1(p);
    float tunnel2 = hitTunnel2(p);
    float hole1 = hitHole1(p);
    float hole2 = hitHole2(p);
    float hole3 = hitHole3(p);
    float tube = hitTube(p);
    float bubble = hitBubble(p);
	//boolean operation mix for CSG
	return max(min(min(-tunnel1, mix(tunnel2, -bubble, 0.375)), max(min(-hole1, hole2), -hole3)), -tube);
}

float speed = iGlobalTime * 0.3;

vec2 rotate(vec2 k, float t)
{	//2d rotation
    return vec2(cos(t) * k.x - sin(t) * k.y, sin(t) * k.x + cos(t) * k.y);
}

void main(void)
{
	//animate camera position
	vec3 cameraPos = vec3(1.0 - 0.325 * sin(speed), 1.0, 0.5 - speed * 2.5);
    
	//calculate ray direction
	vec2 pos = - 1.0 + 2.0 * (gl_FragCoord.xy / iResolution.xy); //[-1..1]
	float aspect = iResolution.x / iResolution.y;
    vec3 dir = normalize(vec3(pos.x * aspect, pos.y, 1.0));
	
	//animate camera direction
	dir.zx = rotate(dir.zx, -speed); // rotation y
	dir.xy = rotate(dir.xy, -0.5 * speed); // rotation z

	//ray cast distance field
    float t = 0.0;
    for(int i = 0; i < 96; ++i)
	{
        float k = draw_scene(cameraPos + dir * t);
        t += k * 0.75;
    }
	vec3 hit = cameraPos + dir * t;
    vec2 h = vec2(-0.0025, 0.002);
    // light
	vec3 n = normalize(vec3(draw_scene(hit + h.xyx), draw_scene(hit + h.yxy), draw_scene(hit + h.yyx)));
    float c = (n.x + n.y + n.z) * 0.35;
    vec3 color = vec3(c,c,c) + t * 0.0625;
    gl_FragColor = vec4(vec3(c - t * 0.0375 + pos.y * 0.05, c - t * 0.025 - pos.y * 0.0625, c + t * 0.025 - pos.y * 0.025) + color * color, 1.0);
}

