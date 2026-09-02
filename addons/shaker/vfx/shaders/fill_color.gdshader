shader_type canvas_item;

uniform vec4 color: source_color;
uniform float force: hint_range(0,1.0);

void fragment() {
	COLOR = mix(COLOR, color, COLOR.a * force);
}
