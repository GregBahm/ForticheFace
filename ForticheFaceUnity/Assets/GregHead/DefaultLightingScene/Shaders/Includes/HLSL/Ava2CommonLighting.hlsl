
#ifndef AVA2_COMMON_LIGHTING
#define AVA2_COMMON_LIGHTING

//--------------------------------------------------------------------------------------------
// This file contains common functions used to compute colors or values used for shading 
// the avatar.
//--------------------------------------------------------------------------------------------

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

#ifdef ENABLE_HSVMASKING
float3 rgb2hsv(float3 c) {
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 hsv2rgb(float3 c) {
    c = float3(c.x, clamp(c.yz, 0.0, 1.0));
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

half3 CalculateHsvColor(half3 baseColor, float hueRange, float satRange, float brightnessRange, half mask)
{
    // FIXME: LinearToGammaSpace is expensive. Work around for content authored in gamma.
#if defined(UNITY_COLORSPACE_GAMMA) || defined(DISABLE_LINEAR_HACKS)
    //hsv color adjust
    float3 hsv = rgb2hsv(baseColor.rgb);
    float3 rgb = hsv2rgb(hsv + float3(hueRange, satRange, brightnessRange));
    return lerp(baseColor.rgb, rgb, mask);
#else
    //hsv color adjust
    float3 hsv = rgb2hsv(LinearToSRGB(baseColor.rgb));
    float3 rgb = hsv2rgb(hsv + float3(hueRange, satRange, brightnessRange));
    return SRGBToLinear(lerp(LinearToSRGB(baseColor.rgb), rgb, mask));
#endif
}
#endif // ENABLE_HSVMASKING

#if defined(RAND_COLOR) || defined(BLIT_MASK_BLEND)
half3 CalculateFullRandomColor(half4 originalColor, half4 mask, half4 primaryColor, half4 secondaryColor, half4 tertiaryColor, half4 quaternaryColor)
{
    // FIXME: LinearToSRGB is expensive. Work around for content authored in gamma.
#if defined(UNITY_COLORSPACE_GAMMA) || defined(DISABLE_LINEAR_HACKS)
    originalColor = lerp(originalColor, primaryColor * originalColor, mask.r);
    originalColor = lerp(originalColor, secondaryColor * originalColor, mask.g);
    originalColor = lerp(originalColor, tertiaryColor * originalColor, mask.b);
    originalColor = lerp(originalColor, quaternaryColor * originalColor, mask.a);
#else
    originalColor.rgb = LinearToSRGB(originalColor.rgb);
    half4 one = half4(LinearToSRGB(primaryColor.rgb), primaryColor.a);
    half4 two = half4(LinearToSRGB(secondaryColor.rgb), secondaryColor.a);
    half4 three = half4(LinearToSRGB(tertiaryColor.rgb), tertiaryColor.a);
    half4 four = half4(LinearToSRGB(quaternaryColor.rgb), quaternaryColor.a);
    originalColor = lerp(originalColor, one * originalColor, mask.r);
    originalColor = lerp(originalColor, two * originalColor, mask.g);
    originalColor = lerp(originalColor, three * originalColor, mask.b);
    originalColor = lerp(originalColor, four * originalColor, mask.a);
    originalColor.rgb = SRGBToLinear(originalColor.rgb);
#endif
    return originalColor.rgb;
}
#endif // RAND_COLOR || BLIT_MASK_BLEND


#if defined(EYE_MAKEUP) || defined(LIP_MAKEUP) || defined(CHEEK_MAKEUP) || defined(BLIT_MAKEUP)
half3 CalculateMakeupColor(half4 originalColor, half4 mask, half4 primaryColor, half4 secondaryColor)
{
    // FIXME: LinearToSRGB is expensive. Work around for content authored in gamma.
#if defined(UNITY_COLORSPACE_GAMMA) || defined(DISABLE_LINEAR_HACKS)
    originalColor = lerp(originalColor, primaryColor, mask.r);
    originalColor = lerp(originalColor, secondaryColor, mask.g);
#else
    primaryColor.rgb = LinearToSRGB(primaryColor.rgb);
    secondaryColor.rgb = LinearToSRGB(secondaryColor.rgb);
    originalColor.rgb = LinearToSRGB(originalColor.rgb);

    originalColor = lerp(originalColor, primaryColor, mask.r);
    originalColor = lerp(originalColor, secondaryColor, mask.g);

    originalColor.rgb = SRGBToLinear(originalColor.rgb);
#endif
    return originalColor.rgb;
}

half3 CalculateMakeupSpec(half4 originalColor, half4 mask, half4 primaryColor, half4 secondaryColor)
{
    originalColor = lerp(originalColor, primaryColor * mask.r, mask.a);
    originalColor = lerp(originalColor, secondaryColor * mask.g, mask.a);

    return originalColor.rgb;
}
#endif // MAKEUP

#if defined(SCALP_STUBBLE) || defined(JAW_STUBBLE) || defined(BLIT_STUBBLE)
half3 CalculateStubble(half4 originalColor, half4 mask, half4 primaryColor)
{
    originalColor = lerp(originalColor, primaryColor, mask.r);

    return originalColor.rgb;
}

half3 CalculateStubbleSpecScatter(half3 originalColor, half4 mask, half dimAmount)
{
    dimAmount = mask.r * dimAmount;
    dimAmount = 1 - dimAmount;
    originalColor *= dimAmount;

    return originalColor.rgb;
}
#endif // STUBBLE

float3 SampleBumpedNormal(TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), float2 uv, half3 tangentWS, half3 bitangentWS, half3 normalWS)
{
    float4 rawNormalTS = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
#if defined(BAKED_NORMALS)
    half3 normalTS = UnpackNormalRGB(rawNormalTS);
#else
    half3 normalTS = UnpackNormal(rawNormalTS);
#endif
    return NormalizeNormalPerPixel(TransformTangentToWorld(normalTS, half3x3(tangentWS, bitangentWS, normalWS)));
}

half4 CalculateSpecularSmoothness(half4 specularSmoothness, float colorStrength, float smoothStrength)
{
    specularSmoothness.a = exp2(10 * specularSmoothness.a + 1) * smoothStrength;
    specularSmoothness.rgb *= colorStrength;
    return specularSmoothness;
}

#endif // AVA2_COMMON_LIGHTING
