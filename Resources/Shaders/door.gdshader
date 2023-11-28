shader_type canvas_item;

uniform float damage_frame;
uniform float immune_frame;

void vertex() {
	VERTEX.y += fract(sin(floor(TIME * 4.)) * 10000.) * 2. * (damage_frame / .1);
}

void fragment() {
	COLOR = texture(TEXTURE, UV)+ vec4(vec3(cos(immune_frame / .3 + UV.y)) * immune_frame / .3, 0.);
}
