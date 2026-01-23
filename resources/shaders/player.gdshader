shader_type canvas_item;

uniform vec3 clr = vec3(0., 0., 1.);

void fragment()
{
    vec2 uv = 2. * UV - 1.0;
    vec2 uv0 = uv;

    float d = 0.002 / (pow(length(uv0) * (0.9 + 0.05 * sin(3. * TIME)), 4.));
	d *= smoothstep(1., 0.7, length(uv0));

    COLOR = vec4(clr, d);
}