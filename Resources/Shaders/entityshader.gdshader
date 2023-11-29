shader_type canvas_item;

uniform int frame = 0;
uniform float firestacks = 0.;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR = COLOR + vec4((vec3(.6, .2, .2) - COLOR.rgb) * (float(frame) / 100.), 0);
	if (firestacks != 0.)
		COLOR.r += (.5 + sin(TIME + UV.x - UV.y) / 2.) * firestacks / 10.;
		COLOR.r += (.5 + cos(TIME + UV.x - UV.y) / 2.) * firestacks / 10.;
		COLOR.g += (.5 + cos(TIME + UV.x - UV.y) / 2.) * firestacks / 10.;
}
