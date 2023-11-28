shader_type canvas_item;

uniform float fade;

void fragment() {
	COLOR = vec4(vec3(0.), pow(UV.x - .5, 2) + pow(UV.y - .5, 2) < fade * 2. ? 1. : 0.);
}
