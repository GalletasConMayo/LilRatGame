shader_type canvas_item;

uniform vec4 color_tile: source_color = vec4(1.0);
uniform float intensity: hint_range(0.0,1.0) = 1;
void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, color_tile.rgb, intensity);
	COLOR = color;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
