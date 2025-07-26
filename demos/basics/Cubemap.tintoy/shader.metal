
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
    texture2d<half> textureA;   // the texture in slot A.
    texture2d<half> textureB;   // the texture in slot B.
    texture2d<half> textureC;   // the texture in slot C.
    texture2d<half> textureD;   // the texture in slot D.
    texturecube<half> cubemap;  // the texture created by the cubemap function.
};

constexpr sampler sampleFilter(mip_filter::linear, 
                               mag_filter::linear, 
                               min_filter::linear);


#pragma mark - Cubemap

float max3(float3 rd) {
   return max(max(rd.x, rd.y), rd.z);
}

float3 cubeFace(float3 rayDirection) {
    float3 rd = abs(rayDirection);
    if (max3(rd) == rd.x) return float3(sign(rayDirection.x), 0, 0);
    if (max3(rd) == rd.y) return float3(0, sign(rayDirection.y), 0);
    if (max3(rd) == rd.z) return float3(0, 0, sign(rayDirection.z));
}


#define C(c) col = mixChar(col,U,c,tex) ; U.x-=.5

half charr(float2 p, int c, texture2d<half> texture) {
    if (p.x<.0|| p.x>1. || p.y<0.|| p.y>1.) return 0.0;
    float2 uv = p/16. + fract( float2(c, c/16) / 16. );
    float2 d = dfdx(p/16.);
    gradient2d grad = gradient2d(d.x, d.y);
    half4 color = texture.sample(sampleFilter, uv, grad);
	return color.x;
}

half4 mixChar(half4 col, float2 p, int c, texture2d<half> texture) {
    half4 amount = charr(p, c, texture);
    return mix(col, half4(0.0, 0.0, 0.0, 1.0), amount);    
}


[[visible]]
half4 mainCubemap(float2 fragCoord, float3 rayOrigin, float3 rayDirection, FragmentUniforms uniforms) {        
    float3 face = cubeFace(rayDirection);
    
    half4 col = half4(half3(abs(face)), 1.0);
    
    
    float2 uv = fragCoord;
    
    uv /= uniforms.resolution.y;
    float FontSize = 24.;
    float2 position = float2((FontSize / 64.0) / 2.0, (FontSize / 64.0));
    float2 U = ( uv - position)*64.0/FontSize;
    
    
    texture2d<half> tex = uniforms.textureA;
    
    if (face.x != 0.0) {
        if (face.x < 0.0) { C('-'); } else { C('+'); }
        C('X');
    }
    if (face.y != 0.0) {
        if (face.y < 0.0) { C('-'); } else { C('+'); }
        C('Y');
    }
    if (face.z != 0.0) {
        if (face.z < 0.0) { C('-'); } else { C('+'); }
        C('Z');
    }
    
    
    
    return half4(half3(col), 1.0);
}


#pragma mark - main

constant float PI = 3.14159265359;

float3x3 camera(float3 cameraPos, float3 lookAtPoint) {
    float3 cd = normalize(lookAtPoint - cameraPos);
    float3 cr = normalize(cross(float3(0, 1, 0), cd));
    float3 cu = normalize(cross(cd, cr));
    
    return float3x3(-cr, -cu, cd);
}

float2x2 rotate2d(float theta) {
  float s = sin(theta), c = cos(theta);
  return float2x2(c, -s, s, c);
}

[[visible]]
half4 mainFragment(float2 fragCoord, FragmentUniforms uniforms) {
    float2 fc = fragCoord;
    float2 uv = (fc - (0.5 * uniforms.resolution.xy)) / uniforms.resolution.y;
    float2 mouse = uniforms.mouse.xy;
    float2 mouseUV = mouse / uniforms.resolution;
    if (mouseUV.x == 0.0 && mouseUV.y == 0.0) {
        mouseUV = float2(0.5);
    }

    float3 lp = float3(0);
    float3 ro = float3(0, 0, 3);
    float mx1 = mix(-PI / 2.0, PI / 2.0, mouseUV.y);
    ro.yz = rotate2d(mx1) * ro.yz;
    float mx2 = mix(-PI, PI, mouseUV.x);
    ro.xz = rotate2d(mx2) * ro.xz;

    float3 rd = camera(ro, lp) * normalize(float3(uv, -0.5));
    
    constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
    half4 color = uniforms.cubemap.sample(colorSampler, rd);

    return color;
}
