shader_type canvas_item;
// Local decorative sprites only: the opaque foot is pinned; collisions never move.
uniform float phase = 0.0;
uniform float amplitude = 0.7;
uniform float foot_y = 0.94;
void vertex() {
	float crown = clamp((foot_y - UV.y) / foot_y, 0.0, 1.0);
	VERTEX.x += sin(TIME * 0.75 + phase) * crown * crown * amplitude;
}
