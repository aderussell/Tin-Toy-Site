// Based on https://www.shadertoy.com/view/XsjXRm

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

//looks best with around 25 rays
#define NUM_RAYS 13.

#define VOLUMETRIC_STEPS 19

#define MAX_ITER 35
#define FAR 6.

#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mat2 float2x2
#define mat3 float3x3

half4 textureLod(const texture2d<half> texture, float2 uv, float lod) {
    constexpr sampler colorSampler(address::repeat,
                                   mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   filter::linear);
    
    half4 result = texture.sample(colorSampler, uv, level(lod));
    return result;
}


mat2 mm2( float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c,-s,s,c);
}

float noise2(float x, const texture2d<half> iChannel0) {
    return textureLod(iChannel0, vec2(x*.01,1.),0.0).x;
}

float hash( float n ) {
    return fract(sin(n) * 43758.5453);
}

float noise(vec3 p, const texture2d<half> iChannel0)
{
    vec3 ip = floor(p);
    vec3 fp = fract(p);
    fp = fp*fp*(3.0-2.0*fp);
    
    vec2 tap = (ip.xy+vec2(37.0,17.0)*ip.z) + fp.xy;
    float2 uv = (tap + 0.5) / 256.0;
    vec2 rg = float2(textureLod( iChannel0, uv, 0.0 ).yx);
    return mix(rg.x, rg.y, fp.z);
}




//See: https://www.shadertoy.com/view/XdfXRj
float flow(vec3 p, float t, float time, const texture2d<half> iChannel0)
{
    mat3 m3 = mat3( 0.00,  0.80,  0.60,
                   -0.80,  0.36, -0.48,
                   -0.60, -0.48,  0.64 );
    
    float z=2.;
    float rz = 0.;
    vec3 bp = p;
    for (float i= 1.; i < 5.; i++ ) {
        p += time * 0.1;
        rz+= (sin(noise(p+t*0.8, iChannel0)*6.)*0.5+0.5) /z;
        p = mix(bp,p,0.6);
        z *= 2.;
        p *= 2.01;
        p *= m3;
    }
    return rz;
}

//could be improved
float sins(float x, float time)
{
     float rz = 0.;
    float z = 2.;
    for (float i= 0.;i < 3.;i++ )
    {
        rz += abs(fract(x*1.4)-0.5)/z;
        x *= 1.3;
        z *= 1.15;
        x -= time*.65*z;
    }
    return rz;
}

float segm( vec3 p, vec3 a, vec3 b)
{
    vec3 pa = p - a;
    vec3 ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1. );
    return length( pa - ba*h )*.5;
}

vec3 path(float i, float d, float time)
{
    vec3 en = vec3(0.,0.,1.);
    float sns2 = sins(d+i*0.5,time)*0.22;
    float sns = sins(d+i*.6,time)*0.21;
    en.xz = mm2((hash(i*10.569)-.5)*6.2+sns2) * en.xz;
    en.xy = mm2((hash(i*4.732)-.5)*6.2+sns) * en.xy;
    return en;
}

vec2 map(vec3 p, float i, float time)
{
    float lp = length(p);
    vec3 bg = vec3(0.);
    vec3 en = path(i,lp,time);
    
    float ins = smoothstep(0.11,.46,lp);
    float outs = .15+smoothstep(.0,.15,abs(lp-1.));
    p *= ins*outs;
    float id = ins*outs;
    
    float rz = segm(p, bg, en)-0.011;
    return vec2(rz,id);
}

float march(vec3 ro, vec3 rd, float startf, float maxd, float j, float time)
{
    float precis = 0.001;
    float h=0.5;
    float d = startf;
    for( int i=0; i<MAX_ITER; i++ )
    {
        if( abs(h)<precis||d>maxd ) break;
        d += h*1.2;
        float res = map(ro+rd*d, j, time).x;
        h = res;
    }
    return d;
}

//volumetric marching
vec3 vmarch(vec3 ro, vec3 rd, float j, vec3 orig, float time, const texture2d<half> iChannel0) {
    vec3 p = ro;
    vec2 r = vec2(0.);
    vec3 sum = vec3(0);
    //float w = 0.;
    for( int i=0; i<VOLUMETRIC_STEPS; i++ )
    {
        r = map(p,j,time);
        p += rd*.03;
        float lp = length(p);
        
        vec3 col = sin(vec3(1.05,2.5,1.52)*3.94+r.y)*.85+0.4;
        col.rgb *= smoothstep(.0,.015,-r.x);
        col *= smoothstep(0.04,.2,abs(lp-1.1));
        col *= smoothstep(0.1,.34,lp);
        sum += abs(col)*5. * (1.2-noise2(lp*2.+j*13.+time*5.0, iChannel0)*1.1) / (log(distance(p,orig)-2.)+.75);
    }
    return sum;
}

//returns both collision dists of unit sphere
vec2 iSphere2(vec3 ro, vec3 rd)
{
    vec3 oc = ro;
    float b = dot(oc, rd);
    float c = dot(oc,oc) - 1.;
    float h = b*b - c;
    if(h <0.0) return vec2(-1.);
    else return vec2((-b - sqrt(h)), (-b + sqrt(h)));
}

[[visible]]
half4 mainFragment(float2 fragCoord, constant FragmentUniforms &uniforms) {
    float time = uniforms.time;
    
    float2 iResolution = uniforms.resolution;
    float4 iMouse = uniforms.mouse;
    const texture2d<half> iChannel0 = uniforms.textureA;
    fragCoord *= iResolution;
    fragCoord.y = iResolution.y - fragCoord.y;
    
    if (iMouse.z < 0 && iMouse.w < 0) {
        iMouse.xy = float2(0);
    }
    
    vec2 p = fragCoord.xy/iResolution.xy-0.5;
    p.x*=iResolution.x/iResolution.y;
    vec2 um = iMouse.xy / iResolution.xy-.5;
    
    //camera
    vec3 ro = vec3(0.,0.,5.);
    vec3 rd = normalize(vec3(p*.7,-1.5));
    mat2 mx = mm2(time*.4+um.x*6.);
    mat2 my = mm2(time*0.3+um.y*6.);
    ro.xz = mx * ro.xz;
    rd.xz = mx * rd.xz;
    ro.xy = my * ro.xy;
    rd.xy = my * rd.xy;
    
    vec3 bro = ro;
    vec3 brd = rd;
    
    vec3 col = vec3(0.0125,0.0,0.025);
    #if 1
    for (float j = 1.;j<NUM_RAYS+1.;j++)
    {
        ro = bro;
        rd = brd;
        mat2 mm = mm2((time*0.1+((j+1.)*5.1))*j*0.25);
        ro.xy = mm * ro.xy;
        rd.xy = mm * rd.xy;
        ro.xz = mm * ro.xz;
        rd.xz = mm * rd.xz;
        float rz = march(ro,rd,2.5,FAR,j,time);
        if ( rz >= FAR)continue;
        vec3 pos = ro+rz*rd;
        col = max(col,vmarch(pos,rd,j, bro, time, iChannel0));
    }
    #endif
    
    ro = bro;
    rd = brd;
    vec2 sph = iSphere2(ro,rd);
    
    if (sph.x > 0.)
    {
        vec3 pos = ro+rd*sph.x;
        vec3 pos2 = ro+rd*sph.y;
        vec3 rf = reflect( rd, pos );
        vec3 rf2 = reflect( rd, pos2 );
        float nz = (-log(abs(flow(rf*1.2,time, time, iChannel0)-.01)));
        float nz2 = (-log(abs(flow(rf2*1.2,-time, time, iChannel0)-.01)));
        col += (0.1*nz*nz* vec3(0.12,0.12,.5) + 0.05*nz2*nz2*vec3(0.55,0.2,.55))*0.8;
    }
    
    return  half4(half3(col), 1.0);
}
