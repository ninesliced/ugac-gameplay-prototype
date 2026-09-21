shader_type canvas_item;

#include "res://addons/shaker/vfx/shaders/rotate.gdshaderinc"

uniform float rotation = 0.115;
uniform float scroll_speed = 0.15;
uniform float scale = 0.75;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 rotated_uv = UV;
	rotated_uv /= scale;
	rotated_uv = rotate(rotated_uv - vec2(TIME) * scroll_speed, rotation);
	
	COLOR = texture(TEXTURE, rotated_uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
