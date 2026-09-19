shader_type canvas_item;

uniform float variant_count;
uniform float frame_count;

varying float variant;
varying float initial_frame;

const float frame_duration = 0.1;

void vertex() {
	variant = INSTANCE_CUSTOM.r;
	initial_frame = INSTANCE_CUSTOM.g;
	
	vec2 shifted_uv = vec2(UV);
	shifted_uv.y *= -1.0;
	
	shifted_uv.y = (shifted_uv.y + variant) / variant_count;
	
	float frame = initial_frame + floor(TIME / frame_duration);
	frame = mod(frame, frame_count);
	
	shifted_uv.x = (shifted_uv.x + frame) / frame_count;
	
	UV = shifted_uv;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
