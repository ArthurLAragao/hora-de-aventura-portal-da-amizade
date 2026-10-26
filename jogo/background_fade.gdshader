shader_type canvas_item;

void fragment() {
	float transition = smoothstep(0.46, 0.54, UV.x);
	vec2 first_uv = vec2(clamp(UV.x * 2.0, 0.0, 1.0), UV.y);
	vec2 next_uv = vec2(0.5 + clamp((UV.x - 0.5) * 2.0, 0.0, 1.0) * 0.5, UV.y);
	vec4 first_scene = texture(TEXTURE, first_uv);
	vec4 next_scene = texture(TEXTURE, next_uv);
	COLOR = mix(first_scene, next_scene, transition);
}
