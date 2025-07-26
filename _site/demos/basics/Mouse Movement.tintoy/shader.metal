
#include <metal_stdlib>
using namespace metal;

struct FragmentUniforms {
    float time;            
    float timeDelta;       
    float frameRate;       
    int frame;            
    int4 date;             
    float2 resolution;  // the resolution of the viewport
    float4 mouse;       // the current mouse position on the viewport as .xy, and press position as .zw
    float4 textureMediaTimes;
    texture2d<half> textureA;
    texture2d<half> textureB;
    texture2d<half> textureC;
    texture2d<half> textureD;
    texturecube<half> cubemap;
};

// calculate the mix proportion for drawing a circle.
float disk(float2 r, float2 center, float radius) {
	return 1.0 - smoothstep( radius-0.0005, radius+0.0005, length(r-center));
}

// background color depends on the x coordinate of the cursor
constant half3 blue   = half3(0.216, 0.471, 0.698);
constant half3 yellow = half3(1.00, 0.329, 0.298);
constant half3 red    = half3(0.867, 0.910, 0.247); 
constant half3 green  = half3(0.117, 0.870, 0.137); 

[[visible]]
half4 mainFragment(float2 fragCoord, FragmentUniforms uniforms) {
    float2 resolution = uniforms.resolution;
    float2 uv = fragCoord / resolution;
    
    // the position of the mouse on the view.
    // the position is provided as a pixel point so must be divided by the 
    // resolution to get the relative position to match the fragCoord
    float2 mouse = uniforms.mouse.xy / resolution;
    
    // the position at which the mouse was pressed on the view.
    // if not pressed then this value will be (-1, -1).
    float2 mousePress = uniforms.mouse.zw / resolution;
	
    // set the inital return color to be the x position of the mouse.
    // if at the very left of the view it will be black, and white at the right.
    half3 finalColor = half3(mouse.x);
	
    // draw a circle to the center-left.
    // if the mouse position is inside the circle then color red, else color yellow
    float2 bigCircleCenter = float2(0.1, 0.5);
    float bigCircleRadius = 0.06;
    half3 bigCircleColor = length(mouse.xy - bigCircleCenter) > bigCircleRadius ? red : yellow;
    finalColor = mix(finalColor, bigCircleColor, disk(uv.xy, bigCircleCenter, bigCircleRadius));	
	// draw the small blue disk at the cursor
	finalColor = mix(finalColor, blue, disk(uv.xy, mouse.xy, 0.02));
    
    // if the mouse if pressed, draw a green circle for the position of the press
    if (mousePress.x >= 0.0) { 
        finalColor = mix(finalColor, green, disk(uv.xy, mousePress, 0.02));
    }
    
    return half4(finalColor, 1.0);
}
