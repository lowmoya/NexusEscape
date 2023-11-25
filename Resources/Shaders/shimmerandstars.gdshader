shader_type canvas_item;

uniform int count;
uniform vec4 points[30];

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR.a != 0.) {
		COLOR.g -= cos(TIME - SCREEN_UV.x + SCREEN_UV.y) / 2.;
	} else {
		for (int i = 0; i < count; i++) {
			if (abs(points[i].x - UV.x) + abs(points[i].y - UV.y) < points[i].w)
				COLOR = vec4(.6, .6, .8, points[i].z / 1.2);
		}
	}
}
