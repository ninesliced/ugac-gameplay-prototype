shader_type canvas_item;

const int MAX_POINTS = 64; 

uniform vec2 points[MAX_POINTS];
uniform float widths[MAX_POINTS];
uniform int point_count = 0;

uniform vec4 stroke_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); 

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

float distance_to_segment(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h);
}

void fragment() {
	bool is_stroke = false;
	
	for (int i = 0; i < point_count; i++) {
		vec2 p1 = points[i];
		vec2 p2 = points[(i + 1) % point_count]; 
		
		float edge_width = widths[i];
		
		float dist = distance_to_segment(local_pos, p1, p2);
		
		// If the pixel is closer to the edge than the assigned width, it's a line
		if (dist < edge_width) {
			is_stroke = true;
			break;
		}
	}
	
	if (is_stroke) {
		COLOR = stroke_color;
	} 
}