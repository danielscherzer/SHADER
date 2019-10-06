#version 120

uniform vec2 iResolution;
uniform float iGlobalTime;
uniform vec3 iMouse;
uniform sampler2D texLastFrame0;

uniform float iThicknessRadius = 0.01;
uniform float iSoftness = 0.01;
uniform vec4 iDrawColor = vec4(0.3, 0.6, 0.4, 1.0);

in vec2 uv;

vec4 oldColor() {
	return texture2D(texLastFrame0, uv);
}

float drawValue()
{
	// here pixels of a circle
	float aspect = iResolution.x / iResolution.y;
	vec2 pos = uv;
	pos.x *= aspect;
	vec2 pmouse = iMouse.xy / iResolution;
	pmouse.x *= aspect;
	float leftDown = clamp(iMouse.z, 0.0, 1.0);
	float circle = 1.0 - smoothstep(iThicknessRadius, iThicknessRadius + iSoftness, distance(pmouse, pos));
	return leftDown * circle;
}

void main() 
{
	vec4 color = iDrawColor * drawValue() + oldColor();
	color = clamp(color, vec4(0), vec4(2.0 - iMouse.z)); //reset with all other mouse buttons
	gl_FragColor = color;
}
