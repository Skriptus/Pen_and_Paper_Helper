shader_type spatial;
render_mode blend_mix;

uniform sampler2D noise;

void vertex(){
	VERTEX.y = float(texture(noise,UV).r)*3.;
}

void fragment(){
	ALBEDO = texture(noise,UV).rgb;
}

