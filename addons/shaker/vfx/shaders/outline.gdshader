shader_type canvas_item;

uniform vec4 color: source_color;
void fragment() {
	float alpha = texture(TEXTURE, vec2(UV.x + TEXTURE_PIXEL_SIZE.x, UV.y)).a +
					texture(TEXTURE, vec2(UV.x - TEXTURE_PIXEL_SIZE.x, UV.y)).a +
					texture(TEXTURE, vec2(UV.x, UV.y + TEXTURE_PIXEL_SIZE.y)).a +
					texture(TEXTURE, vec2(UV.x, UV.y - TEXTURE_PIXEL_SIZE.y )).a +
					- 4.0 * texture(TEXTURE, UV).a;
	COLOR =  mix(COLOR, color, float(alpha > 0.0));
}
