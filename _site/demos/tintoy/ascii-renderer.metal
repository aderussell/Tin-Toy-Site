
// vt220 font from 'vt220 HQ font rendering' by sprash3 https://www.shadertoy.com/view/llSXDV

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

#pragma mark - Text Render

#define PHOSPHOR_COL float4(0.2, 1.0, 0.2, 0.)

float rand(float2 co){
    return fract(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

constant int gradient[] = {0, '.', ':', '-', '=', '+', '*', '#', '%', '@' };


half4 sampleTextureReduced(texture2d<half> iChannel0, float2 fragCoord, float2 iResolution) {
    float2 texResolution = float2(iChannel0.get_width(), iChannel0.get_height());
    
    float downScaleValue = 20.0 * (2.0 * texResolution.x / 1920.0);
    float scale = 1.0 / 1920.0 * downScaleValue;
    
    fragCoord *= iResolution.xy;
    float2 uv = fragCoord / iResolution.xy;
    float2 texFragCoord = uv * texResolution.xy;
    float2 newFragCoord = floor(texFragCoord / downScaleValue) * downScaleValue;
    float2 newUV = newFragCoord / texResolution.xy;
    
    half4 color = iChannel0.read(uint2(newFragCoord), 0);
    return color;
}

float textLines(float2 uvG, float2 fragCoord, constant FragmentUniforms &uniforms) {
    // sample the texture with the render of key and calculate the char for that point as a character to render
    float2 iResolution = uniforms.resolution;
    texture2d<half> iChannel0 = uniforms.textureA;
    half4 color = sampleTextureReduced(iChannel0, fragCoord, iResolution);
    
    int index = int(color.x * 10.0);
    int c = gradient[index];
    return c;
}

// Font Rendering
// From sprash3's shader https://www.shadertoy.com/view/llSXDV
#define l(y,a,b) roundLine(p, float2(float(a), float(y)), float2(float(b), float(y)), iResolution)
float roundLine(float2 p, float2 a, float2 b, float2 iResolution)
{
    b -= a + float2(1.0,0.);
    p -= a;
    float f = length(p-clamp(dot(p,b)/dot(b,b),0.0,1.0)*b);
    if (iResolution.y < 320.) // attempt to get rid of aliasing on small resolution
        return smoothstep(1.0, 0.9, f);
    else if (iResolution.y < 720.)
        return smoothstep(0.75, 0.5, f);
    else
        return smoothstep(1., 0., f);
}


float vt220Font(float2 p, int c, float2 iResolution) {
    if(c==0) return 0.0;
    else if(c==1) return l(3,4,6)+ l(5,3,7)+ l(7,2,8)+ l(9,1,9)+ l(11,2,8)+ l(13,3,7)+ l(15,4,6);
    else if(c==2) return l(3,1,3)+ l(3,4,6)+ l(3,7,9)+ l(5,2,4)+ l(5,6,8)+ l(7,1,3)+ l(7,4,6)+ l(7,7,9)+ l(9,2,4)+ l(9,6,8)+ l(11,1,3)+ l(11,4,6)+ l(11,7,9)+ l(13,2,4)+ l(13,6,8)+ l(15,1,3)+ l(15,4,6)+ l(15,7,9);
    else if(c==3) return l(3,1,3)+ l(3,4,6)+ l(5,1,3)+ l(5,4,6)+ l(7,1,6)+ l(9,1,3)+ l(9,4,6)+ l(11,1,9)+ l(13,5,7)+ l(15,5,7)+ l(17,5,7)+ l(19,5,7);
    else if(c==4) return l(3,1,6)+ l(5,1,3)+ l(7,1,5)+ l(9,1,3)+ l(11,1,3)+ l(11,4,9)+ l(13,4,6)+ l(15,4,8)+ l(17,4,6)+ l(19,4,6);
    else if(c==5) return l(3,2,6)+ l(5,1,3)+ l(7,1,3)+ l(9,1,3)+ l(11,2,8)+ l(13,4,6)+ l(13,7,9)+ l(15,4,8)+ l(17,4,6)+ l(17,7,9)+ l(19,4,6)+ l(19,7,9);
    else if(c==6) return l(3,1,3)+ l(5,1,3)+ l(7,1,3)+ l(9,1,3)+ l(11,1,9)+ l(13,4,6)+ l(15,4,8)+ l(17,4,6)+ l(19,4,6);
    else if(c==7) return l(3,3,7)+ l(5,2,4)+ l(5,6,8)+ l(7,3,7);
    else if(c==8) return l(5,4,6)+ l(7,4,6)+ l(9,1,9)+ l(11,4,6)+ l(13,4,6)+ l(15,1,9);
    else if(c==9) return l(3,1,3)+ l(3,5,7)+ l(5,1,4)+ l(5,5,7)+ l(7,1,7)+ l(9,1,3)+ l(9,4,7)+ l(11,1,3)+ l(11,4,7)+ l(13,4,6)+ l(15,4,6)+ l(17,4,6)+ l(19,4,9);
    else if(c==10) return l(3,1,3)+ l(3,5,7)+ l(5,1,3)+ l(5,5,7)+ l(7,2,6)+ l(9,2,6)+ l(11,3,9)+ l(13,5,7)+ l(15,5,7)+ l(17,5,7)+ l(19,5,7);
    else if(c==11) return l(1,4,6)+ l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,1,6);
    else if(c==12) return l(9,1,6)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6)+ l(17,4,6)+ l(19,4,6);
    else if(c==13) return l(9,4,9)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6)+ l(17,4,6)+ l(19,4,6);
    else if(c==14) return l(1,4,6)+ l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,4,9);
    else if(c==15) return l(1,4,6)+ l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,1,9)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6)+ l(17,4,6)+ l(19,4,6);
    else if(c==16) return l(1,1,9);
    else if(c==17) return l(5,1,9);
    else if(c==18) return l(9,1,9);
    else if(c==19) return l(13,1,9);
    else if(c==20) return l(17,1,9);
    else if(c==21) return l(1,4,6)+ l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,4,9)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6)+ l(17,4,6)+ l(19,4,6);
    else if(c==22) return l(1,4,6)+ l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,1,6)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6)+ l(17,4,6)+ l(19,4,6);
    else if(c==23) return l(1,4,6)+ l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,1,9);
    else if(c==24) return l(9,1,9)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6)+ l(17,4,6)+ l(19,4,6);
    else if(c==25) return l(1,4,6)+ l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,4,6)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6)+ l(17,4,6)+ l(19,4,6);
    else if(c==26) return l(3,7,9)+ l(5,5,7)+ l(7,3,5)+ l(9,1,3)+ l(11,3,5)+ l(13,5,7)+ l(15,7,9)+ l(17,1,9);
    else if(c==27) return l(3,1,3)+ l(5,3,5)+ l(7,5,7)+ l(9,7,9)+ l(11,5,7)+ l(13,3,5)+ l(15,1,3)+ l(17,1,9);
    else if(c==28) return l(7,1,9)+ l(9,3,5)+ l(9,6,8)+ l(11,3,5)+ l(11,6,8)+ l(13,3,5)+ l(13,6,8)+ l(15,2,4)+ l(15,6,8);
    else if(c==29) return l(3,7,9)+ l(5,6,8)+ l(7,1,9)+ l(9,4,6)+ l(11,1,9)+ l(13,2,4)+ l(15,1,3);
    else if(c==30) return l(3,4,8)+ l(5,3,5)+ l(5,7,9)+ l(7,3,5)+ l(9,1,7)+ l(11,3,5)+ l(13,2,7)+ l(15,1,5)+ l(15,6,9)+ l(17,2,4);
    else if(c==31) return l(9,4,6);
    else if(c==32) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,2,5)+ l(9,4,6)+ l(11,4,6)+ l(15,4,6);
    else if(c==33) return l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,4,6)+ l(11,4,6)+ l(15,4,6);
    else if(c==34) return l(3,2,4)+ l(3,5,7)+ l(5,2,4)+ l(5,5,7)+ l(7,2,4)+ l(7,5,7);
    else if(c==35) return l(3,2,4)+ l(3,5,7)+ l(5,2,4)+ l(5,5,7)+ l(7,1,8)+ l(9,2,4)+ l(9,5,7)+ l(11,1,8)+ l(13,2,4)+ l(13,5,7)+ l(15,2,4)+ l(15,5,7);
    else if(c==36) return l(3,4,6)+ l(5,2,8)+ l(7,1,3)+ l(7,4,6)+ l(9,2,8)+ l(11,4,6)+ l(11,7,9)+ l(13,2,8)+ l(15,4,6);
    else if(c==37) return l(3,2,4)+ l(3,7,9)+ l(5,1,5)+ l(5,6,8)+ l(7,2,4)+ l(7,5,7)+ l(9,4,6)+ l(11,3,5)+ l(11,6,8)+ l(13,2,4)+ l(13,5,9)+ l(15,1,3)+ l(15,6,8);
    else if(c==38) return l(3,2,6)+ l(5,1,3)+ l(5,5,7)+ l(7,1,3)+ l(7,5,7)+ l(9,2,6)+ l(11,1,3)+ l(11,5,9)+ l(13,1,3)+ l(13,6,8)+ l(15,2,9);
    else if(c==39) return l(3,4,7)+ l(5,4,6)+ l(7,3,5);
    else if(c==40) return l(3,5,7)+ l(5,4,6)+ l(7,3,5)+ l(9,3,5)+ l(11,3,5)+ l(13,4,6)+ l(15,5,7);
    else if(c==41) return l(3,3,5)+ l(5,4,6)+ l(7,5,7)+ l(9,5,7)+ l(11,5,7)+ l(13,4,6)+ l(15,3,5);
    else if(c==42) return l(5,2,4)+ l(5,6,8)+ l(7,3,7)+ l(9,1,9)+ l(11,3,7)+ l(13,2,4)+ l(13,6,8);
    else if(c==43) return l(5,4,6)+ l(7,4,6)+ l(9,1,9)+ l(11,4,6)+ l(13,4,6);
    else if(c==44) return l(13,3,6)+ l(15,3,5)+ l(17,2,4);
    else if(c==45) return l(9,1,9);
    else if(c==46) return l(13,3,6)+ l(15,3,6);
    else if(c==47) return l(3,7,9)+ l(5,6,8)+ l(7,5,7)+ l(9,4,6)+ l(11,3,5)+ l(13,2,4)+ l(15,1,3);
    else if(c==48) return l(3,3,7)+ l(5,2,4)+ l(5,6,8)+ l(7,1,3)+ l(7,7,9)+ l(9,1,3)+ l(9,7,9)+ l(11,1,3)+ l(11,7,9)+ l(13,2,4)+ l(13,6,8)+ l(15,3,7);
    else if(c==49) return l(3,4,6)+ l(5,3,6)+ l(7,2,6)+ l(9,4,6)+ l(11,4,6)+ l(13,4,6)+ l(15,2,8);
    else if(c==50) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,7,9)+ l(9,4,8)+ l(11,2,5)+ l(13,1,3)+ l(15,1,9);
    else if(c==51) return l(3,1,9)+ l(5,6,8)+ l(7,5,7)+ l(9,4,8)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,2,8);
    else if(c==52) return l(3,5,7)+ l(5,4,7)+ l(7,3,7)+ l(9,2,4)+ l(9,5,7)+ l(11,1,9)+ l(13,5,7)+ l(15,5,7);
    else if(c==53) return l(3,1,9)+ l(5,1,3)+ l(7,1,8)+ l(9,1,4)+ l(9,7,9)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,2,8);
    else if(c==54) return l(3,3,8)+ l(5,2,4)+ l(7,1,3)+ l(9,1,8)+ l(11,1,4)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,2,8);
    else if(c==55) return l(3,1,9)+ l(5,7,9)+ l(7,6,8)+ l(9,5,7)+ l(11,4,6)+ l(13,3,5)+ l(15,3,5);
    else if(c==56) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,7,9)+ l(9,2,8)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,2,8);
    else if(c==57) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,6,9)+ l(9,2,9)+ l(11,7,9)+ l(13,6,8)+ l(15,2,7);
    else if(c==58) return l(5,3,6)+ l(7,3,6)+ l(13,3,6)+ l(15,3,6);
    else if(c==59) return l(5,3,6)+ l(7,3,6)+ l(13,3,6)+ l(15,3,5)+ l(17,2,4);
    else if(c==60) return l(3,7,9)+ l(5,5,7)+ l(7,3,5)+ l(9,1,3)+ l(11,3,5)+ l(13,5,7)+ l(15,7,9);
    else if(c==61) return l(7,1,9)+ l(11,1,9);
    else if(c==62) return l(3,1,3)+ l(5,3,5)+ l(7,5,7)+ l(9,7,9)+ l(11,5,7)+ l(13,3,5)+ l(15,1,3);
    else if(c==63) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,5,8)+ l(9,4,6)+ l(11,4,6)+ l(15,4,6);
    else if(c==64) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,4,9)+ l(9,1,5)+ l(9,6,9)+ l(11,1,3)+ l(11,4,9)+ l(13,1,3)+ l(15,2,8);
    else if(c==65) return l(3,4,6)+ l(5,3,7)+ l(7,2,4)+ l(7,6,8)+ l(9,1,3)+ l(9,7,9)+ l(11,1,9)+ l(13,1,3)+ l(13,7,9)+ l(15,1,3)+ l(15,7,9);
    else if(c==66) return l(3,1,8)+ l(5,2,4)+ l(5,7,9)+ l(7,2,4)+ l(7,7,9)+ l(9,2,8)+ l(11,2,4)+ l(11,7,9)+ l(13,2,4)+ l(13,7,9)+ l(15,1,8);
    else if(c==67) return l(3,3,8)+ l(5,2,4)+ l(5,7,9)+ l(7,1,3)+ l(9,1,3)+ l(11,1,3)+ l(13,2,4)+ l(13,7,9)+ l(15,3,8);
    else if(c==68) return l(3,1,7)+ l(5,2,4)+ l(5,6,8)+ l(7,2,4)+ l(7,7,9)+ l(9,2,4)+ l(9,7,9)+ l(11,2,4)+ l(11,7,9)+ l(13,2,4)+ l(13,6,8)+ l(15,1,7);
    else if(c==69) return l(3,1,9)+ l(5,1,3)+ l(7,1,3)+ l(9,1,7)+ l(11,1,3)+ l(13,1,3)+ l(15,1,9);
    else if(c==70) return l(3,1,9)+ l(5,1,3)+ l(7,1,3)+ l(9,1,7)+ l(11,1,3)+ l(13,1,3)+ l(15,1,3);
    else if(c==71) return l(3,3,8)+ l(5,2,4)+ l(5,7,9)+ l(7,1,3)+ l(9,1,3)+ l(11,1,3)+ l(11,5,9)+ l(13,2,4)+ l(13,7,9)+ l(15,3,8);
    else if(c==72) return l(3,1,3)+ l(3,7,9)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,7,9)+ l(9,1,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,1,3)+ l(15,7,9);
    else if(c==73) return l(3,2,8)+ l(5,4,6)+ l(7,4,6)+ l(9,4,6)+ l(11,4,6)+ l(13,4,6)+ l(15,2,8);
    else if(c==74) return l(3,5,9)+ l(5,6,8)+ l(7,6,8)+ l(9,6,8)+ l(11,6,8)+ l(13,1,3)+ l(13,6,8)+ l(15,2,7);
    else if(c==75) return l(3,1,3)+ l(3,7,9)+ l(5,1,3)+ l(5,5,8)+ l(7,1,6)+ l(9,1,4)+ l(11,1,6)+ l(13,1,3)+ l(13,5,8)+ l(15,1,3)+ l(15,7,9);
    else if(c==76) return l(3,1,3)+ l(5,1,3)+ l(7,1,3)+ l(9,1,3)+ l(11,1,3)+ l(13,1,3)+ l(15,1,9);
    else if(c==77) return l(3,1,3)+ l(3,7,9)+ l(5,1,4)+ l(5,6,9)+ l(7,1,9)+ l(9,1,3)+ l(9,4,6)+ l(9,7,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,1,3)+ l(15,7,9);
    else if(c==78) return l(3,1,3)+ l(3,7,9)+ l(5,1,4)+ l(5,7,9)+ l(7,1,5)+ l(7,7,9)+ l(9,1,3)+ l(9,4,6)+ l(9,7,9)+ l(11,1,3)+ l(11,5,9)+ l(13,1,3)+ l(13,6,9)+ l(15,1,3)+ l(15,7,9);
    else if(c==79) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,7,9)+ l(9,1,3)+ l(9,7,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,2,8);
    else if(c==80) return l(3,1,8)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,7,9)+ l(9,1,8)+ l(11,1,3)+ l(13,1,3)+ l(15,1,3);
    else if(c==81) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,7,9)+ l(9,1,3)+ l(9,7,9)+ l(11,1,3)+ l(11,5,9)+ l(13,1,3)+ l(13,6,8)+ l(15,2,9);
    else if(c==82) return l(3,1,8)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,7,9)+ l(9,1,8)+ l(11,1,3)+ l(11,5,7)+ l(13,1,3)+ l(13,6,8)+ l(15,1,3)+ l(15,7,9);
    else if(c==83) return l(3,2,8)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(9,2,8)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,2,8);
    else if(c==84) return l(3,1,9)+ l(5,4,6)+ l(7,4,6)+ l(9,4,6)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6);
    else if(c==85) return l(3,1,3)+ l(3,7,9)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,7,9)+ l(9,1,3)+ l(9,7,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,2,8);
    else if(c==86) return l(3,1,3)+ l(3,7,9)+ l(5,1,3)+ l(5,7,9)+ l(7,2,4)+ l(7,6,8)+ l(9,2,4)+ l(9,6,8)+ l(11,3,7)+ l(13,3,7)+ l(15,4,6);
    else if(c==87) return l(3,1,3)+ l(3,7,9)+ l(5,1,3)+ l(5,7,9)+ l(7,1,3)+ l(7,7,9)+ l(9,1,3)+ l(9,4,6)+ l(9,7,9)+ l(11,1,3)+ l(11,4,6)+ l(11,7,9)+ l(13,1,9)+ l(15,2,4)+ l(15,6,8);
    else if(c==88) return l(3,1,3)+ l(3,7,9)+ l(5,2,4)+ l(5,6,8)+ l(7,3,7)+ l(9,4,6)+ l(11,3,7)+ l(13,2,4)+ l(13,6,8)+ l(15,1,3)+ l(15,7,9);
    else if(c==89) return l(3,1,3)+ l(3,7,9)+ l(5,2,4)+ l(5,6,8)+ l(7,3,7)+ l(9,4,6)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6);
    else if(c==90) return l(3,1,9)+ l(5,6,8)+ l(7,5,7)+ l(9,4,6)+ l(11,3,5)+ l(13,2,4)+ l(15,1,9);
    else if(c==91) return l(3,3,8)+ l(5,3,5)+ l(7,3,5)+ l(9,3,5)+ l(11,3,5)+ l(13,3,5)+ l(15,3,8);
    else if(c==92) return l(3,1,3)+ l(5,2,4)+ l(7,3,5)+ l(9,4,6)+ l(11,5,7)+ l(13,6,8)+ l(15,7,9);
    else if(c==93) return l(3,2,7)+ l(5,5,7)+ l(7,5,7)+ l(9,5,7)+ l(11,5,7)+ l(13,5,7)+ l(15,2,7);
    else if(c==94) return l(3,4,6)+ l(5,3,7)+ l(7,2,4)+ l(7,6,8)+ l(9,1,3)+ l(9,7,9);
    else if(c==95) return l(15,1,9);
    else if(c==96) return l(3,3,6)+ l(5,4,6)+ l(7,5,7);
    else if(c==97) return l(7,2,8)+ l(9,7,9)+ l(11,2,9)+ l(13,1,3)+ l(13,6,9)+ l(15,2,9);
    else if(c==98) return l(3,1,3)+ l(5,1,3)+ l(7,1,8)+ l(9,1,4)+ l(9,7,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,4)+ l(13,7,9)+ l(15,1,8);
    else if(c==99) return l(7,2,8)+ l(9,1,3)+ l(9,7,9)+ l(11,1,3)+ l(13,1,3)+ l(15,2,9);
    else if(c==100) return l(3,7,9)+ l(5,7,9)+ l(7,2,9)+ l(9,1,3)+ l(9,6,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,6,9)+ l(15,2,9);
    else if(c==101) return l(7,2,8)+ l(9,1,3)+ l(9,7,9)+ l(11,1,9)+ l(13,1,3)+ l(15,2,8);
    else if(c==102) return l(3,4,8)+ l(5,3,5)+ l(5,7,9)+ l(7,3,5)+ l(9,1,7)+ l(11,3,5)+ l(13,3,5)+ l(15,3,5);
    else if(c==103) return l(7,2,9)+ l(9,1,3)+ l(9,6,8)+ l(11,2,7)+ l(13,1,3)+ l(15,2,8)+ l(17,1,3)+ l(17,7,9)+ l(19,2,8);
    else if(c==104) return l(3,1,3)+ l(5,1,3)+ l(7,1,8)+ l(9,1,4)+ l(9,7,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,1,3)+ l(15,7,9);
    else if(c==105) return l(3,4,6)+ l(7,3,6)+ l(9,4,6)+ l(11,4,6)+ l(13,4,6)+ l(15,2,8);
    else if(c==106) return l(3,6,8)+ l(7,6,8)+ l(9,6,8)+ l(11,6,8)+ l(13,6,8)+ l(15,1,3)+ l(15,6,8)+ l(17,1,3)+ l(17,6,8)+ l(19,2,7);
    else if(c==107) return l(3,1,3)+ l(5,1,3)+ l(7,1,3)+ l(7,5,7)+ l(9,1,3)+ l(9,4,6)+ l(11,1,5)+ l(13,1,3)+ l(13,5,7)+ l(15,1,3)+ l(15,7,9);
    else if(c==108) return l(3,3,6)+ l(5,4,6)+ l(7,4,6)+ l(9,4,6)+ l(11,4,6)+ l(13,4,6)+ l(15,3,7);
    else if(c==109) return l(7,1,4)+ l(7,6,8)+ l(9,1,9)+ l(11,1,3)+ l(11,4,6)+ l(11,7,9)+ l(13,1,3)+ l(13,4,6)+ l(13,7,9)+ l(15,1,3)+ l(15,7,9);
    else if(c==110) return l(7,1,8)+ l(9,1,4)+ l(9,7,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,1,3)+ l(15,7,9);
    else if(c==111) return l(7,2,8)+ l(9,1,3)+ l(9,7,9)+ l(11,1,3)+ l(11,7,9)+ l(13,1,3)+ l(13,7,9)+ l(15,2,8);
    else if(c==112) return l(7,1,8)+ l(9,1,4)+ l(9,7,9)+ l(11,1,4)+ l(11,7,9)+ l(13,1,8)+ l(15,1,3)+ l(17,1,3)+ l(19,1,3);
    else if(c==113) return l(7,2,9)+ l(9,1,3)+ l(9,6,9)+ l(11,1,3)+ l(11,6,9)+ l(13,2,9)+ l(15,7,9)+ l(17,7,9)+ l(19,7,9);
    else if(c==114) return l(7,1,3)+ l(7,4,8)+ l(9,2,5)+ l(9,7,9)+ l(11,2,4)+ l(13,2,4)+ l(15,2,4);
    else if(c==115) return l(7,2,8)+ l(9,1,3)+ l(11,2,8)+ l(13,7,9)+ l(15,1,8);
    else if(c==116) return l(3,3,5)+ l(5,3,5)+ l(7,1,7)+ l(9,3,5)+ l(11,3,5)+ l(13,3,5)+ l(13,6,8)+ l(15,4,7);
    else if(c==117) return l(7,1,3)+ l(7,6,8)+ l(9,1,3)+ l(9,6,8)+ l(11,1,3)+ l(11,6,8)+ l(13,1,3)+ l(13,6,8)+ l(15,2,9);
    else if(c==118) return l(7,1,3)+ l(7,7,9)+ l(9,1,3)+ l(9,7,9)+ l(11,2,4)+ l(11,6,8)+ l(13,3,7)+ l(15,4,6);
    else if(c==119) return l(7,1,3)+ l(7,7,9)+ l(9,1,3)+ l(9,7,9)+ l(11,1,3)+ l(11,4,6)+ l(11,7,9)+ l(13,1,9)+ l(15,2,4)+ l(15,6,8);
    else if(c==120) return l(7,1,3)+ l(7,6,8)+ l(9,2,4)+ l(9,5,7)+ l(11,3,6)+ l(13,2,4)+ l(13,5,7)+ l(15,1,3)+ l(15,6,8);
    else if(c==121) return l(7,1,3)+ l(7,6,8)+ l(9,1,3)+ l(9,6,8)+ l(11,1,3)+ l(11,5,8)+ l(13,2,8)+ l(15,6,8)+ l(17,1,3)+ l(17,6,8)+ l(19,2,7);
    else if(c==122) return l(7,1,9)+ l(9,6,8)+ l(11,4,7)+ l(13,3,5)+ l(15,1,9);
    else if(c==123) return l(3,5,9)+ l(5,4,6)+ l(7,5,7)+ l(9,3,6)+ l(11,5,7)+ l(13,4,6)+ l(15,5,9);
    else if(c==124) return l(3,4,6)+ l(5,4,6)+ l(7,4,6)+ l(9,4,6)+ l(11,4,6)+ l(13,4,6)+ l(15,4,6);
    else if(c==125) return l(3,1,5)+ l(5,4,6)+ l(7,3,5)+ l(9,4,7)+ l(11,3,5)+ l(13,4,6)+ l(15,1,5);
    else if(c==126) return l(3,2,5)+ l(3,7,9)+ l(5,1,3)+ l(5,4,6)+ l(5,7,9)+ l(7,1,3)+ l(7,5,8);
    else if(c==127) return l(3,1,5)+ l(5,1,3)+ l(5,4,6)+ l(7,1,3)+ l(7,4,6)+ l(9,1,3)+ l(9,4,6)+ l(11,1,7)+ l(13,3,5)+ l(15,3,5)+ l(17,3,5)+ l(19,3,5);
    else return 0.0;
}

[[visible]]
half4 mainFragment(float2 fragCoord, constant FragmentUniforms &uniforms) {
#define FONT_SIZE float2(10.,20.)
#define ROWCOLS float2(80., 24.)
    
    float2 iResolution = uniforms.resolution;
    float iTime = uniforms.time;
    fragCoord *= iResolution;
    float2 uv = float2(fragCoord.x, fragCoord.y);
    float2 uvT = float2(80, 24) * FONT_SIZE * uv / iResolution.xy;
    float2 uvG = floor(ROWCOLS * uv / iResolution.xy);
    
    float val = textLines(uvG, fragCoord / iResolution, uniforms);
    float4 c = vt220Font(uvT - uvG * FONT_SIZE, val, iResolution) * PHOSPHOR_COL;
    return half4(c);
}
