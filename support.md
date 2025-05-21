---
layout: tintoy
navbar: false
title: Tin Toy
imagebase: "/images/blog/tintoy/"
---

## Creating a shader

A shader within Tin Toy provides a number of defined function signatures for defining your visuals.
Each of these functions is called for every pixel within the destination buffer and the function will return the color to set that pixel.


There are six functions signatures which will be used for creating your images. Each must be marked as `[[visible]]` for Tin Toy to know it is available.

### Main
`mainFragment` is the function for the main buffer which is the final destination and default output for your shader. This function is required for any shader.

```cpp
[[visible]]
half4 mainFragment(float2 fragCoord, constant FragmentUniforms &uniforms) {
    half4 finalColor = half4(0,0,0,1);
    return finalColor;
}
```

It is passed in two parameters; the fragCoord which is the proportional position of the pixel (between 0-1) which will be written to and a struct of the uniform information; this is detailed below.
To get the actual pixel coordinate, multiply the fragCoord by the `uniforms.resolution`.

### Buffers

There are four 2d buffers, the same size as the final main buffer, which can also be used. There function signatures are identical to the main fragment function but with named as `buffer{index}` with their identifiers 'A' to 'D'. For example buffer 'A' looks like:

```cpp
[[visible]]
half4 bufferA(float2 fragCoord, constant FragmentUniforms &uniforms) {  // works for bufferA, bufferB, bufferC, & bufferD
    half4 finalColor = half4(0,0,0,1);
    // perform
    return finalColor;
}
```


### Cubemap
The final is a cubemap.

```cpp
half4 mainCubemap(float2 fragCoord, float3 rayOrigin, float3 rayDirection, constant FragmentUniforms &uniforms) {
    half4 finalColor = half4(0,0,0,1);
    // perform
    return finalColor;
}
```

The fragCoord is the position of the pixel on a face on the cubemap, this means that each fragCoord will be used six times, one for each face.
It receives two more parameters than the other functions; It gets the `rayOrigin`, which is the origin from which the ray would be cast to hit the current pixel, and the `rayDirection` which is the vector direction. The direction can be used to calculate which face of the cubemap is being drawn to.

```cpp
// 1. get largest part of the rayDirection
// 2. calculate the signum to know which side

float max3(float3 rd) {
   return max(max(rd.x, rd.y), rd.z);
}

float3 cubeFace(float3 rayDirection) {
    float3 rd = abs(rayDirection);
    if (max3(rd) == rd.x) return float3(sign(rayDirection.x), 0, 0);
    if (max3(rd) == rd.y) return float3(0, sign(rayDirection.y), 0);
    if (max3(rd) == rd.z) return float3(0, 0, sign(rayDirection.z));
}
```


### The uniforms
Each of the render methods are provided a uniform struct of values with contains the inputs and textures.

```cpp
struct FragmentUniforms {
    float time;                     // the current time through the render in seconds
    float timeDelta;                // the time it takes to render the last frame, in seconds
    float frameRate;                // currently pinned to 60
    int frame;                      // the count of the current frame
    int4 date;                      // the date as year, month, dat, and time in seconds as the .xyzw
    float2 resolution;              // the resolution of the viewport
    float4 mouse;                   // the current mouse position on the viewport as .xy, and the position a left click started as .zw
    float4 textureMediaTimes;       // the times of media for each of the four textures in the x, y, z, & w values. 0 if not applicable.
    texture2d<half> textureA;       // the texture in slot A. If not set in the app it is a default missing-texture appearance.
    texture2d<half> textureB;       // the texture in slot B. If not set in the app it is a default missing-texture appearance.
    texture2d<half> textureC;       // the texture in slot C. If not set in the app it is a default missing-texture appearance.
    texture2d<half> textureD;       // the texture in slot D. If not set in the app it is a default missing-texture appearance. 
    texturecube<half> cubemap;      // the texture created by the cubemap function. A black texture if not implemented.
};

```

These need to be defined at the top of the metal file being rendered and are automatically included in the template file for the shader.


## Providing textures

Much like shadertoy it has the functionality to pass four textures (and a cubemap) to each of the rendering stages. These can be the output buffer of one of the render stages, an image, a frame of a video, a texture with states of keyboard key presses, or the webcam.

These can be specified independently for each stage allowing stages to be changed together.

## Viewing the outputs
When launched, the default output render is the main fragment but it is possible to change to view the output of each buffer, view them all mixed together, and also view the output of the cubemap as either a cubemap or as a equirectangular.

![Changing output](/images/blog/tintoy/changing-views.gif)




## The default shader
The easiest way to start creating a shader is to use the template. This can be created from the 'New from Default Template...' option in the File menu. It will give you a default function for the main shader and the cubemap.

The default shader for the main fragment is a copy of the default used by [shadertoy](https://www.shadertoy.com/new).
It gives a moving gradient of color which changes along with the time.

```cpp
[[visible]]
half4 mainFragment(float2 fragCoord, constant FragmentUniforms &uniforms) {
    float time = uniforms.time;
    float3 color = 0.5 + 0.5 * cos(time + fragCoord.xyx + float3(0,2,4));
    return half4(half3(color), 1.0);
}
```


