shader_type canvas_item;

uniform float frame: hint_range(0.0, 700.);

void
vertex()
{
	if (frame > 0.)
		VERTEX.y += (4. * frame / 200.) * fract(cos(floor(TIME * 6.)) * 1000000.) - 2.;
}

void
fragment()
{
	if (COLOR.r == 0.)
		COLOR.rgb = vec3((cos(TIME * 2.) + 1.) / 2.);
}
