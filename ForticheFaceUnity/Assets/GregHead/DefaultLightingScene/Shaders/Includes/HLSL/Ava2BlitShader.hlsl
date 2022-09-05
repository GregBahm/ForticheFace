#ifndef AVA2_BLIT_SHADER
#define AVA2_BLIT_SHADER

struct appdata_t
{
    float4 vertex : POSITION;
    float2 texcoord : TEXCOORD0;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float2 texcoord : TEXCOORD0;
};

TEXTURE2D(_BlitTex); SAMPLER(sampler_BlitTex);
float4 _BlitTex_ST;

// Discards any pixels outside the atlas region
void ClampToRegion(float2 texcoord)
{
    float borderMask = step(0, texcoord.x);    // Left mask
    borderMask *= (1.0 - step(1, texcoord.x)); // Right mask
    borderMask *= step(0, texcoord.y);         // Bottom mask
    borderMask *= (1.0 - step(1, texcoord.y)); // Top mask
    clip(borderMask < 0.1 ? -1 : 1);
}

float4 NormalMapLerp(TEXTURE2D_PARAM(normalMap, sampler_normalMap), TEXTURE2D_PARAM(normalMap2, sampler_normalMap2), float lerpFactor, float2 texcoord)
{
    float3 normal = UnpackNormal(SAMPLE_TEXTURE2D(normalMap, sampler_normalMap, texcoord));
    float3 normal2 = UnpackNormal(SAMPLE_TEXTURE2D(normalMap2, sampler_normalMap, texcoord));
    float3 resultRGB = 0.5 * lerp(normal, normal2, lerpFactor) + 0.5;
    return float4(resultRGB, 1.0);
}

float CalculateMakeupSpecular(float useMakeup, float originalValue, half mask)
{
    // TODO [alarson] this calculation is performed after lighting is applied in the original shader
    // half3 h = normalize(_WorldSpaceLightPos0.xyz + viewDirection);
    // float nh = max(0, dot(normalDirection, h));
    // float spec = saturate(pow(nh, ((48.0 * shininess) * specularColor.a)));
    // spec += mask * useMakeup * 4

    return originalValue + mask * useMakeup * 4;
}

v2f vert(appdata_t v)
{
    v2f o;
    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    o.texcoord = TRANSFORM_TEX(v.texcoord, _BlitTex);
    return o;
}

half4 frag(v2f i) : SV_Target
{
    ClampToRegion(i.texcoord);
    return SAMPLE_TEXTURE2D(_BlitTex, sampler_BlitTex, i.texcoord);
}
#endif