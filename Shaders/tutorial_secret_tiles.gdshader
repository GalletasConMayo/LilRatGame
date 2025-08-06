shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform float border_size : hint_range(0.0, 0.5) = 0.2;  // Grosor del borde
uniform float blur_size : hint_range(0.0, 0.5) = 0.1;    // Suavidad del difuminado

uniform vec4 color_tile: source_color = vec4(1.0);
uniform float intensity: hint_range(0.0,1.0) = 1;

void fragment() {    vec2 uv = UV;
    
    // Calcular distancia del fragmento al borde más cercano
    float dist_x = min(uv.x, 1.0 - uv.x);
    float dist_y = min(uv.y, 1.0 - uv.y);
    float dist_to_border = min(dist_x, dist_y);

    // Aplicar suavizado en el borde
    float alpha = smoothstep(border_size, border_size + blur_size, dist_to_border);

    // Aplicar transparencia al color de la textura
    vec4 tex_color = texture(TEXTURE, uv);


	//vec4 color = texture(TEXTURE, UV);
	//color.rgb = mix(color.rgb, color_tile.rgb, intensity);
	//COLOR = color;
	
    // Aplicar color con transparencia
	
	tex_color.rgb = mix(tex_color.rgb, color_tile.rgb, intensity);
		
    COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
