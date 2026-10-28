shader_type canvas_item;
render_mode unshaded;
uniform bool powered = false;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	// Only the receiver glass on the right; preserve metal, traces and alpha.
	bool glass = UV.x > 0.875 && UV.x < 0.967 && UV.y > 0.30 && UV.y < 0.68;
	if (!powered && glass && c.r > 0.62 && c.g > 0.48) {
		float value = dot(c.rgb, vec3(0.25, 0.5, 0.25));
		c.rgb = vec3(0.16, 0.25, 0.23) + value * vec3(0.12, 0.15, 0.13);
	}
	COLOR = c * COLOR;
}
