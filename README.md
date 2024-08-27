# Ascii_Shader

- [Ascii\_Shader](#ascii_shader)
  - [Intro](#intro)
  - [Technique](#technique)
    - [Create a full screen quad](#create-a-full-screen-quad)
    - [Make each screen's pixel 8x8](#make-each-screens-pixel-8x8)
    - [Compute pixel luminosity](#compute-pixel-luminosity)
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

| WARNING ⚠️ il metodo è cambiato da Godot 4.2 a 4.3 a causa dell'inserimento del **reverse z buffer**. Leggi quest'articolo per scoprire di più: [Introducing Reverse Z (AKA I'm sorry for breaking your shader)](https://godotengine.org/article/introducing-reverse-z/)

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

Ora 


### Compute pixel luminosity

### Map pixel to character

### Add color

## What I learnd

## Future works

## Credits