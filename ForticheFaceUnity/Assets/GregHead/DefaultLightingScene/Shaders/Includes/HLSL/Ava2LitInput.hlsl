#ifndef AVA2_LIT_INPUT
#define AVA2_LIT_INPUT

//--------------------------------------------------------------------------------------------
// This file contains the following functionalities required for Ava2LitForwardPass.hlsl
//      - Constant buffer layout
//      - Textures
//      - Helper functions for sampling and applying dependent textures
//--------------------------------------------------------------------------------------------

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "./Ava2ShaderVariableFunctions.hlsl"
#include "./Ava2CommonLighting.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
float4 _BumpMap_ST;
float4 _SpecTex_ST;
float4 _BackScatterTexture_ST;
float4x4 _BoneMatrices[128];
float4x4 _BindPoses[128];
CBUFFER_END

TEXTURE2D(_SpecTex);            SAMPLER(sampler_SpecTex);
TEXTURE2D(_BumpMap);            SAMPLER(sampler_BumpMap);
TEXTURE2D(_MainTex);            SAMPLER(sampler_MainTex);
TEXTURE2D(_BackScatterTexture); SAMPLER(sampler_BackScatterTexture);

float4 SampleDiffuse(float2 uv, float strength)
{
    half4 diffuseAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

#ifdef RAND_COLOR
    diffuseAlpha.rgb = CalculateFullRandomColor(diffuseAlpha, SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv), _PrimaryColor, _SecondaryColor, _TertiaryColor, _QuaternaryColor);
#endif
#ifdef SCALP_STUBBLE
    diffuseAlpha.rgb = CalculateStubble(diffuseAlpha, SAMPLE_TEXTURE2D(_ScalpStubbleMaskTex, sampler_ScalpStubbleMaskTex, uv), _ScalpStubbleColor);
#endif
#ifdef JAW_STUBBLE
    diffuseAlpha.rgb = CalculateStubble(diffuseAlpha, SAMPLE_TEXTURE2D(_JawStubbleMaskTex, sampler_JawStubbleMaskTex, uv), _JawStubbleColor);
#endif
#ifdef EYE_MAKEUP
    diffuseAlpha.rgb = CalculateMakeupColor(diffuseAlpha, SAMPLE_TEXTURE2D(_EyeMakeupMaskTex, sampler_EyeMakeupMaskTex, uv), _PrimaryEyeMakeupColor, _SecondaryEyeMakeupColor);
#endif
#ifdef LIP_MAKEUP
    diffuseAlpha.rgb = CalculateMakeupColor(diffuseAlpha, SAMPLE_TEXTURE2D(_LipMakeupMaskTex, sampler_LipMakeupMaskTex, uv), _PrimaryLipMakeupColor, _SecondaryLipMakeupColor);
#endif
#ifdef CHEEK_MAKEUP
    diffuseAlpha.rgb = CalculateMakeupColor(diffuseAlpha, SAMPLE_TEXTURE2D(_CheekMakeupMaskTex, sampler_CheekMakeupMaskTex, uv), _PrimaryCheekMakeupColor, _SecondaryCheekMakeupColor);
#endif

#ifdef CUSTOM_COLOR
    float3 blendedDiffuse = diffuseAlpha.rgb * _Color.rgb;
#ifdef BLEND_COLOR_MASK
    diffuseAlpha.rgb = lerp(diffuseAlpha.rgb, blendedDiffuse, SAMPLE_TEXTURE2D(_BlendMaskTex, sampler_BlendMaskTex, uv).rgb);
#else
    diffuseAlpha.rgb = blendedDiffuse;
#endif
#endif

    diffuseAlpha.rgb *= strength;

    return diffuseAlpha;
}

half3 SampleBackScatterEmission(float2 uv, half NdotL, float strength)
{
#ifdef ENABLE_BACKSCATTER
    // Use the emission component to simulate SSS.
    half4 backScatterTex = SAMPLE_TEXTURE2D(_BackScatterTexture, sampler_BackScatterTexture, uv) * strength;
    half3 backscatter = (1 - NdotL) * _MainLightColor.rgb;

#ifdef CUSTOM_COLOR
    backscatter *= _BackColor.rgb * backScatterTex.r;
#else
    backscatter *= backScatterTex.rgb;
#endif

#ifdef SCALP_STUBBLE
    backscatter.rgb = CalculateStubbleSpecScatter(backscatter, SAMPLE_TEXTURE2D(_ScalpStubbleMaskTex, sampler_ScalpStubbleMaskTex, uv), 1.0);
#endif
#ifdef JAW_STUBBLE
    backscatter.rgb = CalculateStubbleSpecScatter(backscatter, SAMPLE_TEXTURE2D(_JawStubbleMaskTex, sampler_JawStubbleMaskTex, uv), 1.0);
#endif

#else
    half3 backscatter = half3(0, 0, 0);
#endif
    return backscatter;
}

half4 SampleSpecularSmoothness(float2 uv, float colorStrength, float smoothStrength)
{
    // Smoothness scale taken from 
    half4 specularSmoothness = CalculateSpecularSmoothness(SAMPLE_TEXTURE2D(_SpecTex, sampler_SpecTex, uv), colorStrength, smoothStrength);
    
#ifdef SCALP_STUBBLE
    specularSmoothness.rgb = CalculateStubbleSpecScatter(specularSmoothness, SAMPLE_TEXTURE2D(_ScalpStubbleMaskTex, sampler_ScalpStubbleMaskTex, uv), 1.0);
#endif
#ifdef JAW_STUBBLE
    specularSmoothness.rgb = CalculateStubbleSpecScatter(specularSmoothness, SAMPLE_TEXTURE2D(_JawStubbleMaskTex, sampler_JawStubbleMaskTex, uv), 1.0);
#endif

    return specularSmoothness;
}

#endif // AVA2_LIT_INPUT
