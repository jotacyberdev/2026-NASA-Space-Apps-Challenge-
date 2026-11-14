shader_type canvas_item;
render_mode unshaded;

float hash21(vec2 point) {
	point = fract(point * vec2(123.34, 456.21));
	point += dot(point, point + 45.32);
	return fract(point.x * point.y);
}

float noise21(vec2 point) {
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
		value += noise21(point) * amplitude;
		point = mat2(vec2(1.6, 1.2), vec2(-1.2, 1.6)) * point;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 uv = UV;
	float horizon = 0.69;
	float sky_mix = smoothstep(0.02, horizon, uv.y);
	vec3 sky = mix(vec3(0.012, 0.025, 0.064), vec3(0.17, 0.055, 0.075), sky_mix);
	float sunset_band = exp(-pow((uv.y - 0.63) * 17.0, 2.0));
	sky += vec3(0.34, 0.105, 0.045) * sunset_band * 0.58;

	vec2 star_grid = uv * vec2(180.0, 105.0);
	vec2 star_cell = floor(star_grid);
	vec2 star_local = fract(star_grid);
	float star_random = hash21(star_cell);
	vec2 star_center = vec2(hash21(star_cell + 5.2), hash21(star_cell + 17.1)) * 0.78 + 0.11;
	float star_dist = length((star_local - star_center) * vec2(1.0, 0.9));
	float star = (1.0 - smoothstep(0.012, 0.035, star_dist)) * step(0.992, star_random);
	float twinkle = 0.72 + 0.28 * sin(TIME * 1.7 + star_random * 30.0);
	sky += vec3(0.63, 0.79, 0.92) * star * twinkle;

	vec2 planet_center = vec2(0.77, 0.29);
	vec2 planet_delta = (uv - planet_center) * vec2(1.0, 1.18);
	float planet_radius = 0.145;
	float planet_distance = length(planet_delta);
	float planet = 1.0 - smoothstep(planet_radius - 0.002, planet_radius + 0.003, planet_distance);
	float atmosphere = (1.0 - smoothstep(planet_radius, planet_radius + 0.025, planet_distance)) * (1.0 - planet);
	float sphere_light = clamp(0.78 - planet_delta.x * 2.2 + planet_delta.y * 1.1, 0.0, 1.0);
	float planet_noise = fbm(uv * vec2(34.0, 27.0));
	vec3 mars_surface = mix(vec3(0.30, 0.105, 0.075), vec3(0.75, 0.31, 0.15), sphere_light * 0.72 + planet_noise * 0.18);
	float dust_streaks = smoothstep(0.58, 0.79, noise21(vec2(uv.x * 24.0, uv.y * 110.0)));
	mars_surface = mix(mars_surface, vec3(0.90, 0.48, 0.25), dust_streaks * 0.24);
	sky = mix(sky, mars_surface, planet);
	sky += vec3(0.94, 0.31, 0.12) * atmosphere * 0.7;

	float far_noise = fbm(vec2(uv.x * 11.0, 2.4));
	float far_ridge = 0.73 - far_noise * 0.12;
	float far_land = smoothstep(far_ridge - 0.006, far_ridge + 0.006, uv.y);
	vec3 ground_far = mix(vec3(0.23, 0.075, 0.063), vec3(0.43, 0.12, 0.075), fbm(uv * vec2(18.0, 10.0)));
	sky = mix(sky, ground_far, far_land);

	float near_noise = fbm(vec2(uv.x * 8.0 + 1.7, 4.1));
	float near_ridge = 0.84 - near_noise * 0.085;
	float near_land = smoothstep(near_ridge - 0.008, near_ridge + 0.008, uv.y);
	vec3 ground_near = mix(vec3(0.11, 0.038, 0.036), vec3(0.28, 0.075, 0.052), fbm(uv * vec2(32.0, 14.0)));
	sky = mix(sky, ground_near, near_land);

	float base_rect = step(0.18, uv.x) * (1.0 - step(0.42, uv.x)) * step(0.66, uv.y) * (1.0 - step(0.79, uv.y));
	float base_dome = 1.0 - smoothstep(0.06, 0.075, length((uv - vec2(0.30, 0.68)) * vec2(1.0, 1.2)));
	float base = max(base_rect, base_dome * step(0.66, uv.y));
	vec3 base_color = vec3(0.035, 0.055, 0.071);
	sky = mix(sky, base_color, base * 0.95);
	float window_glow = step(0.205, uv.x) * (1.0 - step(0.395, uv.x)) * step(0.715, uv.y) * (1.0 - step(0.73, uv.y));
	sky += vec3(0.15, 0.57, 0.68) * window_glow * 0.38;

	float dust = noise21(vec2(uv.x * 320.0 + TIME * 0.8, uv.y * 90.0));
	float atmosphere_dust = smoothstep(0.68, 0.92, dust) * smoothstep(0.67, 0.91, 1.0 - uv.y);
	sky += vec3(0.48, 0.20, 0.11) * atmosphere_dust * 0.12;
	COLOR = vec4(sky, 1.0);
}
