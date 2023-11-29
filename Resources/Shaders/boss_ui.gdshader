shader_type canvas_item;

uniform bool shake;

void
fragment()
{
	if (COLOR.a == .8) {
		COLOR.a = 1.;
		if (shake) {
			COLOR.r += sin(TIME * 2. + UV.x - UV.y) / 3. + .3333;
		}
	}
}

void
vertex()
{
	if (shake)
		VERTEX.x += 3. * fract(sin(floor(TIME * 11.)) * 10000.);
}