
vec4 drop_shadow(vec2 uv, sampler2D tex, vec4 shadow_color, vec2 shadow_offset) {
	vec4 tex_color = texture(tex, uv);
	float shadow_mask = texture(tex, uv - shadow_offset).a;
	
	float bg_a = shadow_color.a * shadow_mask;
	
	float out_a = tex_color.a + bg_a * (1.0 - tex_color.a);
	vec3 out_rgb = tex_color.rgb;
	
	if (out_a > 0.0001) {
		out_rgb = (tex_color.rgb * tex_color.a + shadow_color.rgb * bg_a * (1.0 - tex_color.a)) / out_a;
	}
	
	return vec4(out_rgb, out_a);
}