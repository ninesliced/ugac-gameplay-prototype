shader_type canvas_item;

uniform float progress : hint_range(0, 1);

uniform float number : hint_range(32.0, 128.0, 1.0);
uniform bool gradient = true;
uniform vec2 screen_size;
//varying float ratio;

float euclidean(float a, float b) {
	return sqrt(pow(a, 2.0) + pow(b, 2));
}

void vertex() {
	//ratio = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
}


void fragment() {
	float ratio = screen_size.y / screen_size.x;
	float frac_x = fract(UV.x * number);
	float frac_y = fract(UV.y * ratio * number);
	float center_x = abs(frac_x - 0.5); // cventer
	float center_y = abs(frac_y - 0.5);// center
	if (center_x + center_y + UV.y * float(gradient) + UV.x * float(gradient) > progress + progress * 4.0 * float(gradient)) {
		discard;
	}
	//COLOR.a = float(ratio < 0.1);
}