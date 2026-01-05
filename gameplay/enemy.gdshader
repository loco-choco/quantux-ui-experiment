shader_type canvas_item;

uniform vec3 clr = vec3(1., 0., 0.);

mat2 rot2D(float theta)
{
    return mat2(vec2(cos(theta), sin(theta)), vec2(-sin(theta), cos(theta)));
}

float sdEquilateralTriangle( in vec2 p, in float r )
{
    float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

void fragment()
{
    vec2 uv = 2. * UV - 1.0;
    vec2 uv0 = uv;
	uv *= rot2D(PI / 6.);
	
    float d = max(0.001, sdEquilateralTriangle(uv * 10., 4.));
	
    d = pow(d, -2);
    d *= smoothstep(1., 0.7, length(uv0));
	
    COLOR = vec4(clr, d);
}