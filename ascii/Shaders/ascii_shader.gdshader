/*
	AUTHOR: Daniel Bologna (call me Dan)
	GIT: https://github.com/AbstractBorderStudio
	ENGINE_VERSION: 4.3
*/

shader_type spatial;
render_mode unshaded;

uniform sampler2D _screen : hint_screen_texture, repeat_disable;
uniform sampler2D _ascii_tex : filter_nearest;
uniform sampler2D _ascii_edge_tex : filter_nearest;

uniform float _char_size = 8.0; // 8 is the ascii character size in the texture (res://Assets/Texture/fillASCII.png) 
uniform float _char_count = 10.0;

vec2 _downscale_tex(vec2 uv, vec2 screen_size, float pixel_size)
{
	return vec2(floor(uv.x * screen_size.x / pixel_size) / screen_size.x * pixel_size, floor(uv.y * screen_size.y / pixel_size) / screen_size.y * pixel_size);
}

float _compute_luminosity(vec3 tex)
{
	// get image luminosity (https://learn.microsoft.com/it-it/windows/win32/medfound/about-yuv-video)
	return 0.2126 * tex.r + 0.7152 * tex.g + 0.0722 * tex.b; // [0, 1]
}

float _quantize(float value, float size)
{
	// value is a [0, 1] range
	// quantize the value as an integer between [0, 1] with a step of 
	return clamp(floor(value * size), 0.0, size - 1.0);
}

vec2 _map_pixel_coord(vec2 fragcoord, float pixel_size)
{
	// clamp pixel coordinate inside a (pixel_size x pixel_size) square
	return vec2(float(int(fragcoord.x) % int(pixel_size)), float(int(fragcoord.y) % int(pixel_size)));
}

float _get_ascii(float index, vec2 coordinate, vec2 uv)
{
	// get the single pixel scale relative to the [0, 1] uv range.
	float x_scale = 1.0 / (_char_count * _char_size);
	float y_scale = 1.0 / _char_size;
	
	// get the coordinate of the (x, y) pixel of the texture and scale the pixel fullscreen to get the color
	vec2 scaled_uv = uv / (vec2(_char_count, 1.0) * _char_size) 		// scale the uv so we have a single pixel from the texture
			+ vec2(x_scale * _char_size * index, 0.0) 					// displace by moving 8 pixel at a time to reach the correct character
			+ vec2(x_scale * coordinate.x, y_scale * coordinate.y); 	// get the (x,y) displaced position inside the character grid
	
	// return the ascii texture sampled in this new uv
	return texture(_ascii_tex, scaled_uv).r;
}

void vertex() 
{
	// godot 4.3 way to set the full screen quad for Screen Space Shaders
	// https://godotengine.org/article/introducing-reverse-z/
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() 
{
	// get screen UV
	vec2 uv = SCREEN_UV;
	
	// make each pixel 8x8 by upscaling, flooring and then re-downscaling the uv
	vec2 downscaled_uv = _downscale_tex(uv, VIEWPORT_SIZE, _char_size);
	
	// sample the texture on the downscaled uv
	vec3 tex = texture(_screen, downscaled_uv).rgb; 

	// quantize colospace to 10 colors to match ascii characters number
	// in this way lm goes from 0 to 9 and we can get correct index from the ascii texture 
	// the floor delets all float values and leaves only the integers [0, 1, ..., 9]
	// allowing omogeneus spread of the characters
	float lm = _quantize(
					_compute_luminosity(tex), 
					_char_count);
	
	// map the pixel position inside an 8x8 square so it goes from 0 to 7
	vec2 pixel_offset = _map_pixel_coord(FRAGCOORD.xy, _char_size);
	
	// get corresponding pixel value based on offset and luminosity from che ascii texture
	float ascii = _get_ascii(lm, pixel_offset, uv);
	
	// clamp the values
	ascii = (ascii > 0.1) ? 1.0 : 0.0;
	
	// add color
	vec3 col = tex * ascii;
	ALBEDO = vec3(ascii);// col;
}
