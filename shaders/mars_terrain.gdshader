shader_type canvas_item;
render_mode unshaded;

uniform vec3 rust_shadow : source_color = vec3(0.19, 0.09, 0.08);
uniform vec3 rust_mid : source_color = vec3(0.46, 0.20, 0.14);
uniform vec3 dust_light : source_color = vec3(0.72, 0.39, 0.25);

float hash21(vec2 point) {
	point = fract(point * vec2(123.34, 456.21));
	point += dot(point, point + 45.32);
	return fract(point.x * point.y);
}

float value_noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	local = local * local * (3.0 - 2.0 * local);
	float a = hash21(cell);
	float b = hash21(cell + vec2(1.0, 0.0));
	float c = hash21(cell + vec2(0.0, 1.0));
	float d = hash21(cell + vec2(1.0, 1.0));
	return mix(mix(a, b, local.x), mix(c, d, local.x), local.y);
}

float fbm(vec2 point) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int octave = 0; octave < 4; octave++) {
		value += value_noise(point) * amplitude;
		point = mat2(vec2(1.6, 1.2), vec2(-1.2, 1.6)) * point;
		amplitude *= 0.5;
	}
	return value;
}

float shallow_crater(vec2 uv, vec2 center, float radius) {
	vec2 delta = (uv - center) * vec2(1.667, 1.0);
	float distance_from_center = length(delta);
	float basin = 1.0 - smoothstep(radius * 0.58, radius, distance_from_center);
	float rim = smoothstep(radius * 0.78, radius * 0.91, distance_from_center)
		* (1.0 - smoothstep(radius * 0.91, radius * 1.12, distance_from_center));
	return basin * 0.045 - rim * 0.028;
}

void fragment() {
	vec2 uv = UV;
	float broad = fbm(uv * vec2(28.0, 20.0));
	float fine = fbm(uv * vec2(190.0, 145.0));
	float grain = value_noise(uv * vec2(780.0, 520.0));
	float dune_warp = fbm(vec2(uv.x * 7.0 + uv.y * 1.8, uv.y * 10.0));
	float dune_wave = sin(uv.y * 48.0 + uv.x * 7.0 + dune_warp * 8.0);
	float dune_ridge = smoothstep(0.58, 0.96, dune_wave * 0.5 + 0.5);
	vec3 ground = mix(rust_shadow, rust_mid, smoothstep(0.20, 0.82, broad));
	ground = mix(ground, dust_light, smoothstep(0.58, 0.88, broad) * 0.42);
	ground *= 0.93 + fine * 0.13;
	ground += (dune_ridge - 0.5) * 0.032;
	ground *= 0.985 + grain * 0.03;
	float craters = shallow_crater(uv, vec2(0.17, 0.24), 0.085)
		+ shallow_crater(uv, vec2(0.63, 0.30), 0.11)
		+ shallow_crater(uv, vec2(0.84, 0.72), 0.075)
		+ shallow_crater(uv, vec2(0.36, 0.81), 0.06);
	ground *= 1.0 - craters;
	COLOR = vec4(ground, 1.0);
}