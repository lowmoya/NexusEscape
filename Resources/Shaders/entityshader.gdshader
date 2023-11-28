shader_type canvas_item;

uniform int frame = 0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR = COLOR + vec4((vec3(.6, .2, .2) - COLOR.rgb) * (float(frame) / 100.), 0);
}
