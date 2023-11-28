shader_type canvas_item;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	if (original == vec4(1, 1, 1, 1)) {
		float component = (cos(TIME * 3. + UV.y) + 1.) / 2.;
		COLOR = vec4(1., 1., component, .7);
		
	} else {
		COLOR = original;
	}
}
