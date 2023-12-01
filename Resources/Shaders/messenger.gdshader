shader_type canvas_item;

void fragment() {
	if (COLOR.a != 0.)
		COLOR.r = COLOR.g = sin(TIME) / 2. + .8;
}