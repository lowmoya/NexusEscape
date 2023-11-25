shader_type canvas_item;

uniform int count;
uniform vec2[10] points;

void fragment() {
	COLOR.a = 0.;
	for (int i = 0; i < count; i++) {
		if (abs(UV.x - points[i].x) + abs(UV.y - points[i].y) < .03){
			COLOR = vec4(1., .64, 1., .8);
			break;
		} else if (pow(UV.x - points[i].x, 2) + pow(UV.y - points[i].y, 2) < .005) {
			COLOR = vec4(.6, .3, .6, .4);
		}
	}
}
