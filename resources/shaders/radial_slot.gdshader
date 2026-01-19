shader_type canvas_item;

uniform float inner_radius : hint_range(0.0, 1.0) = 0.0;
uniform float outer_radius : hint_range(0.0, 1.0)= 1.0;
uniform float arc_angle : hint_range(0.0, 360.0) = 360.0;
uniform float angle_offset : hint_range(0.0, 360.0) = 0.0;

uniform vec4 fill_color: source_color = vec4(vec3(1.0), 1.0);

uniform vec4 outline_color: source_color = vec4(vec3(0.0), 1.0);
uniform float border_width = 0.05;

void fragment() {
	vec4 color = vec4(0.0);
	vec2 centered_uv = (UV * 2.0) - 1.0;
	float dist = length(centered_uv);
	float arc_angle_rad = radians(arc_angle);
	float border_angle = border_width/outer_radius;
	float angle = mod(atan(centered_uv.y, centered_uv.x) +
	              arc_angle_rad / 2.0 + radians(angle_offset), TAU);

	//TODO Make outline code do a better job at the left/right borders
	//And also make this code looks better
	if (dist >= inner_radius && dist <= outer_radius &&
	 	abs(angle) < arc_angle_rad)
		color = fill_color;
	else if (dist >= (inner_radius - border_width)
	    && dist <= (outer_radius + border_width)
		&& (abs(angle - TAU) < border_angle
		||  abs(angle) < arc_angle_rad + border_angle))
		color = outline_color;
	COLOR = color;
}
