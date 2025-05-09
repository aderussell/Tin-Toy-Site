// Based upon https://www.shadertoy.com/view/MtsfD7

#include <metal_stdlib>
using namespace metal;

struct FragmentUniforms {
    float time;
    float timeDelta;
    float frameRate;
    int frame;
    int4 date;
    float2 resolution;
    float4 mouse;
    float4 textureMediaTimes;
    texture2d<half> texture;
    texture2d<half> textureB;
    texture2d<half> textureC;
    texture2d<half> textureD;
    texturecube<half> cubemap;
};

float expStep( float x, float k, float n ) {
    return exp( -k*pow(x,n) );
}

float2x2 rot(float rads) {
    return float2x2(cos(rads), sin(rads), -sin(rads), cos(rads));
}

[[visible]]
half4 mainFragment(float2 fragCoord, constant FragmentUniforms &uniforms) {
    float pi = 3.14159;
    float iTime = uniforms.time;
    float2 p = fragCoord - float2(0.5);
        p = rot(iTime * 1.25) * p;
        p = float2(p.x, -p.y) + .15;
        
        float r = length(p);
        float a = atan2(p.y, p.x);
        a += 2. * sin(a);
        float coord = fract(a / pi + expStep(r, 1., .5) * 8. + 1.6 * iTime);
    float3 col = mix(float3(.17, 0., .25), float3(.3, 0., .5), step(.6, coord));
        
        col *= pow(r, .65) * 1.75;
        col;
    
    return half4(half3(col), 1.0);
}
