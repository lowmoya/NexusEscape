shader_type canvas_item;

uniform float frame;

void
fragment()
{
	float sqr_dist = pow(UV.x - .5, 2.) + pow(UV.y - .5, 2.);
	COLOR.a = sqr_dist * 10. - frame;
}
