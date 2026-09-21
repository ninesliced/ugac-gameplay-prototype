vec2 rotate(vec2 vec, float rotation) {
	float c = cos(rotation);
	float s = sin(rotation);
	
	return vec2(
		vec.x * c - vec.y * s,
		vec.x * s + vec.y * c
	);
}