// Based on https://www.shadertoy.com/view/sslBDj

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
    texture2d<half> textureA;
    texture2d<half> textureB;
    texture2d<half> textureC;
    texture2d<half> textureD;
    texturecube<half> cubemap;
};

[[visible]]
half4 mainFragment(float2 U, constant FragmentUniforms &uniforms) {
    half4 O = half4(0.0);
    
    float2 R = uniforms.resolution.xy;
    U *= R;
    U.y = R.y - U.y;
    float iTime = uniforms.time;
    U *= 7./R;
    O-=O;
    for(float i=0.,a,z = 1.5+.5*sin(iTime/2.); i++ < 70.; )
            a = z* ( U.x + sin( i/6. + iTime ) ),
            O = mix(O, half4(int(i)%2)* ( .7 - .3*sin(a) ),
                    smoothstep(0.,15./R.y, 10.-i/6. + 2./z*cos(a) - U.y ) );
    
    return O;
}
