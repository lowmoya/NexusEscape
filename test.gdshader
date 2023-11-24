shader_type canvas_item;

void fragment() {
	COLOR = vec4(0, .4, .6, .6);
	float distance = pow(UV.x - .5, 2.) + pow(UV.y - .5, 2.);
	if (distance > .2)
		COLOR.a = 0.;
	else if (distance > .19)
		COLOR.a = 1.;
	else
		COLOR.r = fract(sin(floor((UV.x + UV.y * 100.) * 30.) + TIME)*100000.);
}
