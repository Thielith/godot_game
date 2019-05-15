shader_type canvas_item;

uniform float amplitudeAxisY = 1.0;
uniform float amplitudeAxisX = 1.0;
uniform float wavesY = 2.0;
uniform vec4 shadow_color : hint_color;

void vertex(){
	VERTEX.y += cos((TIME + VERTEX.x) * wavesY) * amplitudeAxisY;
	VERTEX.x += sin(TIME + VERTEX.x) * amplitudeAxisX;
}