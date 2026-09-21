shader_type canvas_item;

uniform float scale = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV * scale;
	COLOR = texture(TEXTURE, vec2(uv.x - TIME, uv.y));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
