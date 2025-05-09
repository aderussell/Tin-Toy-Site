//
//  Modified from Heartfelt by Martijn Steinrucken aka BigWings
//  https://www.shadertoy.com/view/ltffzl
//

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

//#define S(a, b, t) smoothstep(a, b, t)
//#define CHEAP_NORMALS
#define USE_POST_PROCESSING

float3 N13(float p) {
    //  from DAVE HOSKINS
   float3 p3 = fract(float3(p) * float3(.1031,.11369,.13787));
   p3 += dot(p3, p3.yzx + 19.19);
   return fract(float3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

float4 N14(float t) {
    return fract(sin(t * float4(123., 1024., 1456., 264.)) * float4(6547., 345., 8799., 1564.));
}
float N(float t) {
    return fract(sin(t*12345.564) * 7658.76);
}

float Saw(float b, float t) {
    return smoothstep(0., b, t) * smoothstep(1., b, t);
}

half4 sampleLod(const texture2d<half> texture, float2 uv, float lod) {
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   filter::linear);
    
    half4 result = texture.sample(colorSampler, uv, level(lod));
    return result;
}


float2 DropLayer2(float2 uv, float t) {
    float2 UV = uv;
    
    uv.y += t*0.75;
    float2 a = float2(6., 1.);
    float2 grid = a*2.;
    float2 id = floor(uv*grid);
    
    float colShift = N(id.x);
    uv.y += colShift;
    
    id = floor(uv*grid);
    float3 n = N13(id.x*35.2+id.y*2376.1);
    float2 st = fract(uv*grid)-float2(.5, 0);
    
    float x = n.x-.5;
    
    float y = UV.y*20.;
    float wiggle = sin(y+sin(y));
    x += wiggle*(.5-abs(x))*(n.z-.5);
    x *= .7;
    float ti = fract(t+n.z);
    y = (Saw(.85, ti)-.5)*.9+.5;
    float2 p = float2(x, y);
    
    float d = length((st-p)*a.yx);
    
    float mainDrop = smoothstep(.4, .0, d);
    
    float r = sqrt(smoothstep(1., y, st.y));
    float cd = abs(st.x-x);
    float trail = smoothstep(.23*r, .15*r*r, cd);
    float trailFront = smoothstep(-.02, .02, st.y-y);
    trail *= trailFront*r*r;
    
    y = UV.y;
    float trail2 = smoothstep(.2*r, .0, cd);
    float droplets = max(0., (sin(y*(1.-y)*120.)-st.y))*trail2*trailFront*n.z;
    y = fract(y*10.)+(st.y-.5);
    float dd = length(st - float2(x, y));
    droplets = smoothstep(.3, 0., dd);
    float m = mainDrop+droplets*r*trailFront;
    
    //m += st.x>a.y*.45 || st.y>a.x*.165 ? 1.2 : 0.;
    return float2(m, trail);
}

float StaticDrops(float2 uv, float t) {
    uv *= 40.;
    
    float2 id = floor(uv);
    uv = fract(uv)-.5;
    float3 n = N13(id.x*107.45+id.y*3543.654);
    float2 p = (n.xy-.5)*.7;
    float d = length(uv-p);
    
    float fade = Saw(.025, fract(t+n.z));
    float c = smoothstep(.3, 0., d) * fract(n.z*10.) * fade;
    return c;
}

float2 Drops(float2 uv, float t, float l0, float l1, float l2) {
    float s = StaticDrops(uv, t)*l0;
    float2 m1 = DropLayer2(uv, t)*l1;
    float2 m2 = DropLayer2(uv*1.85, t)*l2;
    
    float c = s+m1.x+m2.x;
    c = smoothstep(.3, 1., c);
    
    return float2(c, max(m1.y*l0, m2.y*l1));
}

[[visible]]
half4 mainFragment(float2 fragCoordI, constant FragmentUniforms &uniforms) {
    float2 fragCoord = fragCoordI * uniforms.resolution;
    fragCoord.y = uniforms.resolution.y - fragCoord.y;
//    float3 iMouse = uniforms.mouse.xyz;
    float3 iResolution = float3(uniforms.resolution, 1.0);
    float iTime = uniforms.time;
    
    float2 uv = (fragCoord.xy-.5*iResolution.xy) / iResolution.y;
    float2 UV = fragCoord.xy/iResolution.xy;
    float3 M = float3(0.0);
    float T = iTime+M.x*2.;
    
    
    float t = T*.2;
    
    float rainAmount = 0.95;
    
    float maxBlur = mix(3., 6., rainAmount);
    float minBlur = 2.;
    
    float story = 0.;
    float heart = 0.;
    
    float zoom = -cos(T*.2);
    uv *= .7+zoom*.3;
    UV = (UV-.5)*(.9+zoom*.1)+.5;
    
    float staticDrops = smoothstep(-.5, 1., rainAmount)*2.;
    float layer1 = smoothstep(.25, .75, rainAmount);
    float layer2 = smoothstep(.0, .5, rainAmount);
    
    
    float2 c = Drops(uv, t, staticDrops, layer1, layer2);
   #ifdef CHEAP_NORMALS
    float2 n = float2(dFdx(c.x), dFdy(c.x));// cheap normals (3x cheaper, but 2 times shittier ;))
    #else
    float2 e = float2(.001, 0.);
        float cx = Drops(uv+e, t, staticDrops, layer1, layer2).x;
        float cy = Drops(uv+e.yx, t, staticDrops, layer1, layer2).x;
    float2 n = float2(cx-c.x, cy-c.x);        // expensive normals
    #endif
    
    
    
    float focus = mix(maxBlur-c.y, minBlur, smoothstep(.1, .2, c.x));
    texture2d<half> texture = uniforms.texture;
    float2 sampleUV = UV+n;
    sampleUV.y = 1.0 - sampleUV.y;
    float3 col = float3(sampleLod(texture, sampleUV, focus).rgb);
    
    
    #ifdef USE_POST_PROCESSING
    t = (T+3.)*.5;                                        // make time sync with first lightnoing
    float colFade = sin(t*.2)*.5+.5+story;
    col *= mix(float3(1.), float3(.8, .9, 1.3), colFade);    // subtle color shift
    float fade = smoothstep(0., 10., T);                            // fade in at the start
    float lightning = sin(t*sin(t*10.));                // lighting flicker
    lightning *= pow(max(0., sin(t+sin(t))), 10.);        // lightning flash
    col *= 1.+lightning*fade*mix(1., .1, story*story);    // composite lightning
    col *= 1.-dot(UV-=.5, UV);                            // vignette
    
    col *= fade;                                        // composite start and end fade
    #endif
    
    return half4(half3(col), 1.);
}
