shader_type canvas_item;

uniform int frame = 0;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec3 offset = vec3(.6, .2, .2) - original.rgb;
	float progress = float(frame) / 100.;
	COLOR =  original + vec4(offset.r * progress, offset.g * progress, offset.b * progress, 0);
}
