shader_type canvas_item;

uniform vec2 scroll_offset;
uniform float zoom = 1.0;
uniform vec4 dot_color : source_color = vec4(0.2, 0.22, 0.28, 1.0); // Subtle dot color
uniform vec4 bg_color : source_color = vec4(0.067, 0.075, 0.094, 1.0); // #111318

void fragment() {
	// Spacing in pixels is 28.0 * zoom
	float spacing = 28.0 * zoom;
	
	// We want the dots to scroll with pan.
	// FRAGCOORD.xy is in screen space (pixels).
	// We offset by scroll_offset to match the panning.
	vec2 grid_pos = FRAGCOORD.xy + scroll_offset;
	
	// Find local position within the cell
	vec2 cell_pos = mod(grid_pos, spacing);
	
	// Distance from the center of the dot
	float dist = length(cell_pos - vec2(spacing * 0.5));
	
	// Dot radius in screen pixels (scale slightly with zoom, e.g. 1.25 pixels radius for sharp dots)
	float dot_radius = 1.25 * clamp(zoom, 0.5, 2.0);
	
	// Antialiasing border
	float aa = 0.5;
	float dot_mask = smoothstep(dot_radius + aa, dot_radius - aa, dist);
	
	COLOR = mix(bg_color, dot_color, dot_mask);
}
