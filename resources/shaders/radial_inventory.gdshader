shader_type canvas_item;

uniform vec2 mousePos = vec2(1., 1.);
uniform float wheelScale = 1.;

void fragment()
{
	vec2 uv = 2. * UV - 1.0;
	uv *= wheelScale;
	
	float radius = 0.7;
	float width = 0.2;
	
	vec2 mouseDir = mousePos;
	if(length(mouseDir) > 1.) mouseDir = normalize(mouseDir);
	float distortion = dot(mouseDir, normalize(uv));
	distortion = smoothstep(0.0, 1., distortion);
	distortion = pow(distortion, 1.);
	
	float sq = uv.x * uv.x + uv.y * uv.y - radius;
	if(sq <= width - 0.2 && sq >= -width - 0.3 + 0.063 * distortion)
	{
		COLOR = vec4(0.074, 0.102, 0.216, 1.0);
	}
	else
		COLOR = vec4(0., 0., 0., 0.);
	
	float circleSize = 0.66 + 0.2 * distortion;
	float dstToRing = 0.04 / abs(dot(uv * 3.3, uv) - circleSize);
	float dstToOuterRing = 0.04 / abs(dot(uv * 2.3, uv) - 1.61);
	COLOR = COLOR + (max(dstToRing, dstToOuterRing)) * vec4(0.08, 0.2, 0.3, 0.9);
}
