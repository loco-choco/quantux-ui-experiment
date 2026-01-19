shader_type canvas_item;

uniform vec3 clr = vec3(1., 0., 0.);

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

void fragment()
{
    vec2 uv = 2. * UV - 1.0;
    vec2 uv0 = uv;
    //uv *= 1.3;

    //uv *= vec2(1., 5.);
    //float n = 4.;
    //float d = pow(pow(abs(uv.x), n) + pow(abs(uv.y), n), 1. / n);
    //float d = max(abs(uv.x), abs(uv.y));
	
	float d = max(0., sdSegment(uv, vec2(-0.35, 0.), vec2(0.35, 0.)));
	
    d = pow(d, -2);
	d *= 0.005;
    d *= smoothstep(1., 0.8, length(uv0));
    d = clamp(0., 1., d);
    
    COLOR = vec4(clr, d);
}