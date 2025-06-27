var vertCode = `#version 300 es
#ifdef GL_ES
precision highp float;
precision highp int;
precision mediump sampler3D;
#endif
layout(location = 0) in vec2 coordinates;
void main(void) {
    gl_Position = vec4(coordinates, 0.0, 1.0);
}
`

const fragCode = `#version 300 es
#ifdef GL_ES
precision highp float;
precision highp int;
precision mediump sampler3D;
#endif
#define HW_PERFORMANCE 1


uniform vec3 iResolution;
uniform float iTime;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;

void mainImage(out vec4 fragColor, in vec2 fragCoord);
out vec4 outColor;
void main(void) {
	vec4 outputColor = vec4(0.0);
	vec2 fragCoord = gl_FragCoord.xy;
	mainImage(outputColor, fragCoord);
	outColor = outputColor;
}

#define half3 vec3
#define half4 vec4
#define float2 vec2
#define float3 vec3
#define float4 vec4
#define float3x3 mat3

// #pragma mark - Tin Toy Key Render

float3x3 rotate_y(float a){
    float sa = sin(a); float ca = cos(a);
    return float3x3(float3(ca,.0,sa),
                    float3(.0,1.,.0),
                    float3(-sa,.0,ca)
                    );
}

float3x3 rotate_x(float a){
    float sa = sin(a); float ca = cos(a);
    return float3x3(float3(1.,.0,.0),
                    float3(.0,ca,-sa),
                    float3(.0,sa,ca)
                    );
}

float opExtrusion( float3 p, float sdf, float h )
{
    float2 w = float2( sdf, abs(p.z) - h );
      return min(max(w.x,w.y),0.0) + length(max(w,0.0));
}

float opUnion( float d1, float d2 )
{
    return min(d1,d2);
}

float opSubtraction( float d1, float d2 )
{
    return max(-d1,d2);
}

float opIntersection( float d1, float d2 )
{
    return max(d1,d2);
}

float opSmoothUnion( float d1, float d2, float k )
{
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}

float opSmoothSubtraction( float d1, float d2, float k )
{
    return -opSmoothUnion(d1,-d2,k);
}

float opSmoothIntersection( float d1, float d2, float k )
{
    return -opSmoothUnion(-d1,-d2,k);
}

float opRound( float k, float rad )
{
    return k - rad;
}


float opXor(float d1, float d2 )
{
    return max(min(d1,d2),-max(d1,d2));
}

//-------------------------------------------------



float sdTorus( float3 p, float2 t )
{
    return length( float2(length(p.xz)-t.x,p.y) )-t.y;
}

float sdRoundBox( float3 p, float3 b, float r )
{
  float3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)) - r;
}

float sdCappedCylinder( float3 p, float3 a, float3 b, float r )
{
  float3  ba = b - a;
  float3  pa = p - a;
  float baba = dot(ba,ba);
  float paba = dot(pa,ba);
  float x = length(pa*baba-ba*paba) - r*baba;
  float y = abs(paba-baba*0.5)-baba*0.5;
  float x2 = x*x;
  float y2 = y*y*baba;
  float d = (max(x,y)<0.0)?-min(x2,y2):(((x>0.0)?x2:0.0)+((y>0.0)?y2:0.0));
  return sign(d)*sqrt(abs(d))/baba;
}

//---------------------------------

float sdCircle(float2 p, float r) {
  return length(p) - r;
}

float sdBox( float2 p, float2 b )
{
    float2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdRoundedBox( float2 p, float2 b, float4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    float2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

// Create the 2D shape for the top of the key. It will be extruded into 3D.
float sdFlatKey(float2 p) {
    float2 q = p;

    float cylinder1 = sdCircle( q-float2(-1.0,0.5), 0.55 );
    float cylinder2 = sdCircle( q-float2(1.0,0.5), 0.55 );
    
    float d1 = sdCircle( q-float2(-1.0,0.5), 0.3 );
    float d2 = sdCircle( q-float2(1.0,0.5), 0.3 );
    
    
    float cyl = opSmoothUnion(cylinder1, cylinder2, 0.2);
    float r = sdRoundedBox(q-float2(0.0, -0.1), float2(0.5, 0.8), float4(0.1));
    float dt = opSmoothUnion(cyl,r, 0.55);
    
    dt = opSubtraction(d1, dt);
    dt = opSubtraction(d2, dt);
    return dt;
}

//---------------------------------


float map_full(float3 pos, float time, inout int type) {
    float d = 1e10;
    
    
   // time += 3.1415;
    float extraScale = 0.85;
    float3 q = (pos * extraScale) - float3(0, 0.7, 0);// * rotate_y(time * 1.0);
    
    float3 q2 = pos * rotate_y(time * -1.0);
    
    float key = sdFlatKey(q.xy);
    d = opExtrusion( q, key, 0.05 ) - 0.02;
    
    float dSub = opExtrusion( q, key, 0.07 );
    
    
    float cyl = sdCappedCylinder(q, float3(0.0,0.0,0.0), float3(0.0,-2.5,0.0), 0.25);
    cyl = opRound(cyl, 0.05);
    cyl = opSmoothSubtraction(dSub, cyl, 0.03);
    
    // make indents for cylinder being attached to handle
    float hole = sdCappedCylinder(q, float3(0.0,-0.4,-1.0), float3(0.0,-0.4,-0.27), 0.1);
    float hole2 = sdCappedCylinder(q, float3(0.0,-0.4, 1.0), float3(0.0,-0.4, 0.27), 0.1);
    cyl = opSubtraction(hole, cyl);
    cyl = opSubtraction(hole2, cyl);
    
    float ring = sdTorus(q + float3(0.0,1.0,0.0), float2(0.3, 0.01));
    cyl = opSmoothSubtraction(ring, cyl, 0.005);
    
    d = opUnion(d, cyl);
    
    q *= rotate_y(-time);
//    float c = sdRoundBox(q2 - float3(0.0,-1.9, 0.0), float3(1.6, 0.1, 1.6), 0.1);
    float c = sdCappedCylinder(q2, float3(-3.0,-11.5,0.0), float3(3.0,-11.5,-0.0), 10.0);
    float cylF = sdCappedCylinder(q2, float3(0.0,0.0,0.0), float3(0.0,-2.0,0.0), 0.4 / extraScale);
    c = opSmoothSubtraction(cylF, c, 0.04);
    
    if (c < d) {
        type = 2;
    } else {
        type = 1;
    }

    d = opUnion(d,c);
    
    return d;
}

float map(float3 pos, float time) {
    int i = 0;
    return map_full(pos, time, i);
}

// https://iquilezles.org/articles/nvscene2008/rwwtt.pdf
float calcAO(float3 pos, float3 nor, float time)
{
    float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float h = 0.01 + 0.12*float(i)/4.0;
        float d = map( pos + h*nor, time );
        occ += (h-d)*sca;
        sca *= 0.95;
        if( occ>0.35 ) break;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 ) * (0.5+0.5*nor.y);
}

// https://iquilezles.org/articles/normalsSDF
float3 calcNormal( float3 pos, float time )
{
    const float ep = 0.0001;
    float2 e = float2(1.0,-1.0)*0.5773;
    return normalize( e.xyy*map( pos + e.xyy*ep, time ) +
                      e.yyx*map( pos + e.yyx*ep, time ) +
                      e.yxy*map( pos + e.yxy*ep, time ) +
                      e.xxx*map( pos + e.xxx*ep, time ) );
}

// https://iquilezles.org/articles/rmshadows
float calcSoftshadow( float3 ro, float3 rd, float tmin, float tmax, const float k, float time )
{
    float res = 1.0;
    float t = tmin;
    for( int i=0; i<50; i++ )
    {
        float h = map( ro + rd*t, time );
        res = min( res, k*h/t );
        t += clamp( h, 0.02, 0.20 );
        if( res<0.005 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );
}

bool squircle(vec2 fragCoord) {
    vec2 uv = fragCoord;

    vec2 pos = vec2(0.0,0.0);

    float power = 5.0;
    float radius = 0.7;
    float dist = pow(abs(uv.x-pos.x),power) + pow(abs(uv.y - pos.y),power);
	return ( dist < pow(radius,power));
}

vec2 skew(vec2 fragCoord, float proportion) {
    vec2 n = fragCoord;
    n.x += (sign(fragCoord.x) * (fragCoord.y) * proportion);
    n.y += (sign(fragCoord.y) * (fragCoord.y) * proportion);
    return n;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    float3 tot = float3(0.0);
    
    float alpha = 0.0;
    
  
        // pixel coordinates
        float2 p = (-iResolution.xy + 2.0*fragCoord)/iResolution.y;
 
        
        float3 ro = float3(0.0,0.0,9.0);
        float3 rd = normalize(float3(p,-3.5));

        //iTime += 3.1415;
        ro *= rotate_y(iTime * 1.0);
        rd *= rotate_y(iTime * 1.0);

        float t = 7.0;
        int type = 0;
        for( int i=0; i<64; i++ )
        {
            float3 p = ro + t*rd;
            float h = map_full(p, iTime, type);
            if( abs(h)<0.001 || t>11.0 ) break;
            t += h;
        }

        float3 col = float3(0.0);

        if( t<11.0 )
        {
            float3 pos = ro + t*rd;
            float3 pos_still = pos * rotate_y(iTime * -1.0);
            float3 nor = calcNormal(pos, iTime);
            float3 lig = normalize(float3(0.4,0.9,0.7)) * rotate_y(iTime * 1.0);
            float dif = clamp(dot(nor, lig), 0.0, 1.0);
            float sha = calcSoftshadow( pos, lig, 0.001, 1.0, 16.0, iTime );
            float amb = 0.5 + 0.5*nor.y;
            
            float2 posXY = pos.xy;
            posXY.x /= 4.0;
            posXY.y /= 5.0;
            half4 sc =  texture(iChannel0, posXY - float2(0.5)) / 2.0;
            float3 sc_f = float3(sc.xyz) * 1.5;
            
            if (type != 2) {
                nor += (sc_f - float3(0.5)) / 1.5;
            } else {
                half4 sc = texture(iChannel1, (pos_still.xz * pos_still.y / 2.0) - float2(0.5)) / 2.0;
                float3 sc_f = float3(sc.xyz);
                nor -= (sc_f - float3(0.5)) / 6.0;
            }
            
            float3 ref = reflect( rd, nor );
            
            float occ = calcAO( pos, nor, iTime );
            
            float3 half_way = normalize(-rd + lig);
            float specular = pow(clamp(dot(half_way,nor),0.0,1.0), 80.0);
            
            
            
            float ks = 1.0;
            
            float3 col2 = float3(0.0);
            if (type == 2) {
//                col2 += float3(0.95,0.0,0.00) * amb;
//                col2 += float3(1.00,0.01,0.01) * dif * sha;
                
                
                half4 sc = texture(iChannel1, (pos_still.xz * pos_still.y / 2.0) - float2(0.5)) / 2.0;
                float3 sc_f = float3(sc.xyz) * float3(0.5,1.0,0.0) / 2.0;
                
               // col2 = float3(0.95,0.0,0.00) * sc_f;
                col2 = float3(0.25,0.0,0.00) + sc_f;
                
                if (abs(pos_still.x) > 0.8 && abs(pos_still.x) < 1.4) {
                    col2 = float3(0.2) + sc_f;
                }
                col2 /= 1.5;
                col2 += pow(clamp(dot(half_way,nor),0.0,1.0), 40.0);
            } else {
//                col2 += float3(0.05,0.1,0.15) * amb * sc_f;
//                col2 += float3(1.00,0.9,0.80) * dif * sha * sc_f;
                col2 = sc_f;
                col2 += specular;
            }
            
        //    col *= occ;
            
            // sun
            {
              //  float3  lig = normalize( float3(-0.5, 0.4, -0.6) );
                float3  hal = normalize( lig-rd );
                float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
              //if( dif>0.0001 )
                      dif *= calcSoftshadow( pos, lig, 0.02, 2.5, 1.0, iTime );
                float spe = pow( clamp( dot( nor, hal ), 0.0, 1.0 ),16.0);
                      spe *= dif;
                      spe *= 0.04+0.96*pow(clamp(1.0-dot(hal,lig),0.0,1.0),5.0);
                    //spe *= 0.04+0.96*pow(clamp(1.0-sqrt(0.5*(1.0-dot(rd,lig))),0.0,1.0),5.0);
                col += col2 * 2.20 * dif * float3(1.30,1.00,0.70);
                col +=     5.00*spe*float3(1.30,1.00,0.70)*ks;
            }
      
            // sky
            {
                float dif = sqrt(clamp( 0.5+0.5*nor.y, 0.0, 1.0 ));
                      dif *= occ;
                float spe = smoothstep( -0.2, 0.2, ref.y );
                      spe *= dif;
                      spe *= 0.04+0.96*pow(clamp(1.0+dot(nor,rd),0.0,1.0), 5.0 );
              //if( spe>0.001 )
                      spe *= calcSoftshadow( pos, ref, 0.02, 2.5, 1.0, iTime );
                col += col2*0.60*dif*float3(0.40,0.60,1.15);
                col +=     2.00*spe*float3(0.40,0.60,1.30)*ks;
            }
            
            
            alpha = 1.0;
        }

        col = sqrt( col );
        tot += col;



    vec4 backgroundOther = vec4(0.1333333333, 0.1333333333, 0.1333333333, 1);
    vec4 iconBackground = vec4(vec3(8.0/255.0), 1.0);
    
    
    float3 ro2 = float3(0.0,0.0,9.0);
    
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 uvSq = -1.0 + 2.0 * q;
    uvSq.x *= iResolution.x/iResolution.y;
    
  
//    uvSq = skew(uvSq, ((sin(iTime / 1.0) + 1.0) - 1.0) / 4.0);
    
    bool inSquircle = squircle(uvSq.xy);
    fragColor = half4( half3(tot) , alpha );
    
    if (!inSquircle) {
    
        if ((fragCoord.y / iResolution.y) < 0.5) {
            fragColor = backgroundOther;
        } else {
            fragColor = mix(fragColor, backgroundOther, 1.0 - fragColor.w);
        }
    } else {
	        fragColor.xyz = mix(half3(tot), iconBackground.xyz, 1.0 - alpha);
            fragColor.w = 1.0;
    }

}
`

function setup(gl, canvas) {

    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);

    var vertices = [1,-1, 1,1, -1,-1, -1,1];
    var vertex_buffer = gl.createBuffer();

    // create vertex buffer
    gl.bindBuffer(gl.ARRAY_BUFFER, vertex_buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
    gl.bindBuffer(gl.ARRAY_BUFFER, null);

	
	// create vertex shader
	var vertexShader = gl.createShader(gl.VERTEX_SHADER);
	gl.shaderSource(vertexShader, vertCode);
	gl.compileShader(vertexShader);

	// create fragment shader
	var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
	gl.shaderSource(fragmentShader, fragCode);
	gl.compileShader(fragmentShader);

	// create the program
    var shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);

    var compiled = gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS);
    var info = gl.getShaderInfoLog(fragmentShader);

    gl.linkProgram(shaderProgram);
    gl.useProgram(shaderProgram);

    var timeLocation = gl.getUniformLocation(shaderProgram, "iTime");
    gl.uniform1f(timeLocation, 0.0);


    var width = canvas.width;
    var height = canvas.height;
    var resolutionLocation = gl.getUniformLocation(shaderProgram, "iResolution");
    gl.uniform3f(resolutionLocation, width, height, 1.0);

    var texture0Location = gl.getUniformLocation(shaderProgram, "iChannel0");
    gl.uniform1i(texture0Location, 0);

    var texture1Location = gl.getUniformLocation(shaderProgram, "iChannel1");
    gl.uniform1i(texture1Location, 1);

    var texture = gl.createTexture();
	gl.bindTexture(gl.TEXTURE_2D, texture);
	 
	// Fill the texture with a 1x1 blue pixel.
	gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE,
	              new Uint8Array([0, 0, 255, 255]));
	 
	// Asynchronously load an image
	var image = new Image();
	image.src = "_tintoy/metal.png";
	image.addEventListener('load', function() {
	  // Now that the image has loaded make copy it to the texture.
	  gl.bindTexture(gl.TEXTURE_2D, texture);
	  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA,gl.UNSIGNED_BYTE, image);
	  gl.generateMipmap(gl.TEXTURE_2D);
	});


    // bind buffer objects
    gl.bindBuffer(gl.ARRAY_BUFFER, vertex_buffer);
    var coord = gl.getAttribLocation(shaderProgram, "coordinates");
    gl.vertexAttribPointer(coord, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(coord);

    gl.viewport(0,0,width * 1,height * 1);

    //#222
    gl.clearColor(0.00, 0.00, 0.00, 1);

    //Set the color with the color buffer
    gl.clear(gl.COLOR_BUFFER_BIT);

    return shaderProgram;
}