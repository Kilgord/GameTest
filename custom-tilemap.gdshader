shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.r > 0.95 && color.g > 0.95 && color.b > 0.95)
	{
		color.a = 0.0;
	}
	COLOR = color;
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
