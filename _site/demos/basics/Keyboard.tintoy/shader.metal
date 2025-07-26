
#include <metal_stdlib>
using namespace metal;

struct FragmentUniforms {
    float time;                     // the current time through the render in seconds
    float timeDelta;                // the time it takes to render the last frame, in seconds
    float frameRate;                // currently pinned to 60
    int frame;                      // the count of the current frame
    int4 date;                      // the date as year, month, dat, and time in seconds as the .xyzw
    float2 resolution;              // the resolution of the viewport
    float4 mouse;                   // the current mouse position on the viewport as .xy, and the position a left click started as .zw
    float4 textureMediaTimes;       // the times of media for each of the four textures in the x, y, z, & w values. 0 if not applicable.
    texture2d<half> textureA;       // the texture in slot A.
    texture2d<half> textureB;       // the texture in slot B.
    texture2d<half> textureC;       // the texture in slot C.
    texture2d<half> textureD;       // the texture in slot D.
    texturecube<half> cubemap;      // the texture created by the cubemap function.
};

constant int KEY_LEFT  = 37;
constant int KEY_UP    = 38;
constant int KEY_RIGHT = 39;
constant int KEY_DOWN  = 40;

float3 circle(float2 uv, float2 center, float3 color, int key, texture2d<half> iChannel0) {
    float3 col = float3(0.0);
    // state
    col = mix( col, color, 
        (1.0-smoothstep(0.3,0.31,length(uv-center)))*
        (0.3+0.7* iChannel0.read(uint2(key,0)).x) );
    // keypress	
    col = mix( col, color, 
        (1.0-smoothstep(0.0,0.01,abs(length(uv-center)-0.35)))*
        iChannel0.read( uint2(key,1),0 ).x);
    // toggle	
    col = mix( col, color, 
        (1.0-smoothstep(0.0,0.01,abs(length(uv-center)-0.3)))*
        iChannel0.read( uint2(key,2),0 ).x);
    return col;
}

[[visible]]
half4 mainFragment(float2 fragCoord, FragmentUniforms uniforms) {
    float2 iResolution = uniforms.resolution;
    float2 uv = (-iResolution.xy + 2.0 * fragCoord) / iResolution.y;
    uv.y *= -1.0;

    float3 col = float3(0.0);
    
    texture2d<half> iChannel0 = uniforms.textureA;

    
    col += circle(uv, float2(-0.65,0.0), float3(1.0,0.0,0.0), KEY_LEFT, iChannel0);
    
    
    col += circle(uv, float2(0.0,0.5), float3(1.0,1.0,0.0), KEY_UP, iChannel0);
    
    
    col += circle(uv, float2(0.65,0.0), float3(0.0,1.0,0.0), KEY_RIGHT, iChannel0);
    
    
    col += circle(uv, float2(0.0,-0.5), float3(0.0,0.0,1.0), KEY_DOWN, iChannel0);

    return half4(half3(col),1.0);
}
