shader_type canvas_item;
#include "res://addons/shaker/vfx/shaders/rotate.gdshaderinc"
#include "res://addons/shaker/vfx/shaders/drop_shadow.gdshaderinc"

uniform vec4 shadow_color: source_color = vec4(0.0, 0.0, 0.0, 0.2); 
uniform vec2 shadow_offset = vec2(0.0, 0.04);
uniform float rotate_speed = 0.3;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv_shifted = rotate(UV - vec2(0.5), TIME * rotate_speed) + vec2(0.5);
	vec2 shadow_uv = rotate((UV - shadow_offset) - vec2(0.5), TIME * rotate_speed) + vec2(0.5);
	
	vec4 tex_color = texture(TEXTURE, uv_shifted);
	float shadow_mask = texture(TEXTURE, shadow_uv).a;
	
	float bg_a = shadow_color.a * shadow_mask;
	
	float out_a = tex_color.a + bg_a * (1.0 - tex_color.a);
	vec3 out_rgb = tex_color.rgb;
	
	if (out_a > 0.0001) {
	    out_rgb = (tex_color.rgb * tex_color.a + shadow_color.rgb * bg_a * (1.0 - tex_color.a)) / out_a;
	}
	
	COLOR = vec4(out_rgb, out_a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
