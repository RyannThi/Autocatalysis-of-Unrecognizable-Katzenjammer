texture2D ScreenTexture:POSTEFFECTTEXTURE;
sampler2D ScreenTextureSampler = sampler_state {
    texture = <ScreenTexture>;
    AddressU  = MIRROR;
    AddressV = MIRROR;
    Filter = MIN_MAG_LINEAR_MIP_POINT;
};
float4 screen : SCREENSIZE;
float3x3 m = {
               0.00f,  0.80f,  0.60f,
              -0.80f,  0.36f, -0.48f,
              -0.60f, -0.48f,  0.64f
             };
float Scale1 < string binding = "Scale1"; > = 0.1f;
float Scale2 < string binding = "Scale2"; > = 3.5f;
float Amp < string binding = "Amp"; > = 20.0f;
float FreqX < string binding = "FreqX"; > = 30.0f;
float FreqY < string binding = "FreqY"; > = 30.0f;
float iTime < string binding = "timer"; > = 1.0f;

float hash(float n)
{
    float x = sin(n) * 43758.5453f;
    return x - floor(x);
}
float noise( float3 x )
{
    float3 p = floor(x);
    float3 f = x - floor(x);

    f = f * f * (3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = lerp(lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
                          lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                     lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
                          lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}
float myfbm( float3 p )
{
    float f;
    f  = 0.5000f * noise(p); p = mul(m, p) * 2.02f;
    f += 0.2500f * noise(p); p = mul(m, p) * 2.03f;
    f += 0.1250f * noise(p); p = mul(m, p) * 2.01f;
    f += 0.0625f * noise(p); p = mul(m, p) * 2.05f;
    f += 0.0625f/2.0f * noise(p); p = mul(m, p) * 2.02f;
    f += 0.0625f/4.0f * noise(p);
    return f;
}
float4 PS_MainPass(float4 position:POSITION, float2 uv:TEXCOORD0):COLOR
{
    float3 v;
    float3 p = Scale2 * float3(uv, 0.0f) - iTime;
   	float x = myfbm(p);
   	v = (0.5f + 0.5f * sin(x * float3(FreqX, FreqY, 1.0) * Scale1)) / Scale1;
   	v *= Amp;
   	float4 Ti = tex2D(ScreenTextureSampler, uv - v.xy/float2(640,480) + float2(0.0775*Amp/5, 0.103*Amp/5));
   	Ti.a = 1.0f;
   	return Ti;
}

technique Main
{
    pass MainPass
    {
        PixelShader = compile ps_3_0 PS_MainPass();
    }
}
