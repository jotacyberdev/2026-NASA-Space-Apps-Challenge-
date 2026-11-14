shader_type canvas_item;
render_mode unshaded;

uniform float strength : hint_range(0.0, 0.5) = 0.24;

void fragment() {
	vec2 centered = (UV - vec2(0.5)) * vec2(1.72, 1.0);
	float edge = smoothstep(0.38, 1.04, length(centered));
	COLOR = vec4(vec3(0.008, 0.018, 0.026), edge * strength);
}