
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

constexpr sampler sampleFilter(mip_filter::linear,
                               mag_filter::linear,
                               min_filter::linear);

#define C(c) O+= charr(U,c,tex) ; U.x-=.5

#define LF (U.y--)
#define CR (U.x = (( uv.x - position.x)*64.0/FontSize))
#define NL (CR,LF)

half4 textureGrad(texture2d<half> texture, float2 uv, float2 gr, float2 dy) {
    
    half4 color = texture.sample(sampleFilter, uv, gradient2d(gr.x, dy.y));
    return color;
}

half4 charr(float2 p, int c, texture2d<half> iChannel0) {
    if (p.x<.0|| p.x>1. || p.y<0.|| p.y>1.) 
        return half4(0,0,0,1);

    float2 uv = p/16. + fract( float2(c, c/16) / 16. );
    return textureGrad( iChannel0, uv, dfdx(p/16.),dfdy(p/16.) );
}


[[visible]]
half4 mainFragment(float2 fragCoord, constant FragmentUniforms &uniforms) {
    float2 uv = fragCoord /= uniforms.resolution.y;
    texture2d<half> tex = uniforms.textureA;
    
    half4 O = half4(0.0);

    float FontSize = 4.;
    float2 position = float2(0, FontSize / 64.0);
    float2 U = ( uv - position)*64.0/FontSize;
    C('H');C('E');C('L');C('L');C('O');C(' ');C('W');C('O');C('R');C('L');C('D');C('!');
    NL;
    C('L');C('O');C('V');C('E');C(' ');C('T');C('I');C('N');C(' ');C('T');C('O');C('Y');C('!');
    O = O.xxxx * 2.0;
    
    return O;
}
