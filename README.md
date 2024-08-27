# Ascii_Shader

- [Ascii\_Shader](#ascii_shader)
  - [Intro](#intro)
  - [Technique](#technique)
    - [Create a full screen quad](#create-a-full-screen-quad)
    - [Make each screen's pixel 8x8](#make-each-screens-pixel-8x8)
    - [Compute pixel luminosity](#compute-pixel-luminosity)
    - [Quantize the luminosity values to the ascii character count](#quantize-the-luminosity-values-to-the-ascii-character-count)
    - [Map pixel to character](#map-pixel-to-character)
    - [Add color](#add-color)
  - [What I learnd](#what-i-learnd)
  - [Future works](#future-works)
  - [Credits](#credits)

## Intro
This shader is inspired by the ascii shader by Acerola [I Tried Turning Games Into Text](https://www.youtube.com/watch?v=gg40RWiaHRY)

![Sample](imgs/duck.gif)

It is not the same as Acerola's implementation. In fact, it lacks of the edge detection pass. I'll try to implement this later on this year.

## Technique

### Create a full screen quad

Follow the [Advanced post-processing](https://docs.godotengine.org/en/stable/tutorials/shaders/advanced_postprocessing.html) page from godot documentation.  

- Create a `MeshInstance3D`
- set it as a quad size 2x2 and flip the face
  - warining NOT the transform but the _quad size_.

![setting](imgs/setting.png)

- Add a `ShaderMaterial` in Geometry>MaterialOverride

in the vertex shader just add this line:

```
void vertex() 
{
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}
```

After doing this your screen should be all white-ish.

> ⚠️ WARNING ⚠️ 
> 
> method changed from Godot 4.2 to 4.3 because of the introduction of the **reverse z buffer**. Read this article to find out more: [Introducing Reverse Z (AKA I'm sorry for breaking your shader)](https://godotengine.org/article/introducing-reverse-z/)

### Make each screen's pixel 8x8

![start](imgs/start.png)

Now, I'm using a 8x8 pixel ascii character like in the Acerola's video, so I need to make the screen pixel 8x8. This means taking the screen texture, enlarging it 8 times, flooring the value to delete all in-between values, and then donwscaling back to normal.

I did this transformation to the `SCREEN_UV`, than sample the screen texture on this downsampled uv.

```
vec2 down_sampled_uv = vec2(
                floor(uv.x * screen_size.x / pixel_size) / screen_size.x * pixel_size, 
                floor(uv.y * screen_size.y / pixel_size) / screen_size.y * pixel_size);
```

In Godot 4.3

- screen_size: `VIEWPORT_SIZE`
- pixel_size: `8.0` <- è la dimensione del carattere ascii


![downsample](imgs/downsample.png)

Now the screen should be made of 8x8 pixels, indipendenlty of the screen res.

### Compute pixel luminosity

Compute the pixel luminosity using the YUV formula ([About YUV Video](https://learn.microsoft.com/en-us/windows/win32/medfound/about-yuv-video)):

```
float _compute_luminosity(vec3 tex)
{
	return 0.2126 * tex.r + 0.7152 * tex.g + 0.0722 * tex.b; // [0, 1]
}
```

> As you can see the luminosity is a single channel value. In order to display it you should use something like:

```
ALBEDO = vec3(luminosity);
```

![lum](imgs/lum.png)

### Quantize the luminosity values to the ascii character count

Now we need to make the shades of gray of the luminosity fall in a range of fixed values eaquale to the number of character we want to use.

To do so we can multiply the range by the count of character, then flooring the result to delete all in-between values and then dividing by 8.

```
float _quantize(float value, float size)
{
	// value is a [0, 1] range
	// quantize the value as an integer between [0, 1] with a step of 1 / size
	return clamp(floor(value * size) / size, 0.0, 1.0);
}
```

In this way we have values between 0 and 1 with a step of 1/char_count. For instance, I use 10 ascii character so I'll have values like:

[0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]

![quantize](imgs/quantize.png)

We have 8 shades!

> ⚠️ WARNING ⚠️ 
>
> Because of my naive implementation I forgot to divide by the size, so my values go from 0 to 9
> 
> [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
>
> and the result looks burnt but **the information is still there**:
>
> ![quantize_burnt](imgs/quantize_burnt.png)
>
> I will leave it like this.

### Map pixel to character

### Add color

## What I learnd

## Future works

## Credits