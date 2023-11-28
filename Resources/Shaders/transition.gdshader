shader_type canvas_item;

void fragment() {
	if (UV.y < .2)
		COLOR = vec4(vec3(0.), 1.);
	else
		COLOR = vec4(vec3(0.), 1. - (UV.y - .2) / .8);
}
