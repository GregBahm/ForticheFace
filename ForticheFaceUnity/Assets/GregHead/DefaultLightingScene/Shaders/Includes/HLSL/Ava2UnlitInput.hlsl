#ifndef AVA2_UNLIT_INPUT
#define AVA2_UNLIT_INPUT

//--------------------------------------------------------------------------------------------
// This file contains the following functionalities required for Ava2UnlitForwardPass.hlsl
//      - Constant buffer layout
//      - Textures
//      - Helper functions for sampling and applying dependent textures
//--------------------------------------------------------------------------------------------

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
float4x4 _BoneMatrices[128];
float4x4 _BindPoses[128];
CBUFFER_END

TEXTURE2D(_MainTex);            SAMPLER(sampler_MainTex);

float4 SampleDiffuse(float2 uv, float strength)
{
    half4 diffuseAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
    diffuseAlpha.rgb *= strength;
    return diffuseAlpha;
}

#endif // AVA2_UNLIT_INPUT
