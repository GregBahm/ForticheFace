#ifndef AVA2_LIT_FORWARD_PASS
#define AVA2_LIT_FORWARD_PASS

//--------------------------------------------------------------------------------------------
// This file contains the Vertex and Fragment shader for a Default Lit avatar.
//--------------------------------------------------------------------------------------------

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "./Ava2Skinning.hlsl"
#include "./Ava2Lighting.hlsl"

struct Attributes 
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;

#ifdef AVATAR_GPU_SKINNING
    float4 boneWeights01 : TEXCOORD1;
    float4 boneWeights23 : TEXCOORD2;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float2 uv : TEXCOORD1;
    half3 normalWS : TEXCOORD2;
    half3 tangentWS : TEXCOORD3;
    half3 bitangentWS : TEXCOORD4;
    half3 viewDirectionWS : TEXCOORD5;

#if !defined(_RECEIVE_SHADOWS_OFF)
    float4 shadowCoord : TEXCOORD6;
#endif

    UNITY_VERTEX_OUTPUT_STEREO
};

void ConvertToUnityInputData(in Varyings input, in float3 normalWS, inout InputData data)
{
    data.positionWS = input.positionWS;
    data.normalWS = normalWS;
    data.viewDirectionWS = input.viewDirectionWS;
    data.fogCoord = 1;
    data.vertexLighting = half3(0, 0, 0);
    data.bakedGI = SampleSH(data.normalWS);
    data.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

#if !defined(_RECEIVE_SHADOWS_OFF)
    data.shadowCoord = input.shadowCoord;
#endif
}

Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

#ifdef AVATAR_GPU_SKINNING
    ApplySkinning(input.positionOS.xyz, input.normalOS, input.boneWeights01, input.boneWeights23, output.positionWS, output.normalWS);
    ComputeTangents(output.normalWS, input.tangentOS, output.tangentWS, output.bitangentWS);

    output.positionCS = TransformWorldToHClip(output.positionWS);
#else
    output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.normalWS = normalInput.normalWS;
    output.tangentWS = normalInput.tangentWS;
    output.bitangentWS = normalInput.bitangentWS;
#endif
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    output.viewDirectionWS = normalize(GetWorldSpaceViewDir(output.positionWS));

#if !defined(_RECEIVE_SHADOWS_OFF)
    VertexPositionInputs vertexInput = GetVertexPositionInputs(output.positionWS, output.positionCS);
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

    return output;
}

half4 LitPassFragment(Varyings input) : SV_Target
{
    // FIXME: Some constant scalars to compensate for some things.
#if defined(DISABLE_LINEAR_HACKS)
    const float BackScatterStrength = 1;
    const float DiffuseStrength = 1;
    const float SpecularStrength = 1;
    const float SmoothnessStrength = 1;
#else
    const float BackScatterStrength = 2;
    const float DiffuseStrength = 2;
    const float SpecularStrength = 1;
    const float SmoothnessStrength = 0.5;
#endif
    const float WrapMultiplier = 1.25;
    const float WrapOffset = 1.0;

    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float3 normalDirection = SampleBumpedNormal(TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), input.uv, input.tangentWS, input.bitangentWS, input.normalWS);

#if defined(SECOND_BUMPMAP)
    float3 normalDirection2 = SampleBumpedNormal(TEXTURE2D_ARGS(_BumpMap2, sampler_BumpMap2), input.uv, input.tangentWS, input.bitangentWS, input.normalWS);
    normalDirection = lerp(normalDirection, normalDirection2, _BumpLerp);
#endif

    half NdotL = saturate(dot(normalDirection, _MainLightPosition.xyz));
    half4 diffuseAlpha = SampleDiffuse(input.uv, DiffuseStrength);
    half3 backscatter = SampleBackScatterEmission(input.uv, NdotL, BackScatterStrength);
    half4 specularSmoothness = SampleSpecularSmoothness(input.uv, SpecularStrength, SmoothnessStrength);
    half3 emission = half3(0, 0, 0);

    InputData data = (InputData)0;
    ConvertToUnityInputData(input, normalDirection, data);

#ifdef ENABLE_HSVMASKING
    half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.uv);
    diffuseAlpha.rgb = CalculateHsvColor(diffuseAlpha.rgb, _HueRange, _SatRange, _BrightnessRange, mask.r);
#endif

#ifdef USE_UNITYLIGHTING
    float4 outColor = UniversalFragmentBlinnPhong(data, diffuseAlpha.rgb, specularSmoothness, specularSmoothness.a, emission, diffuseAlpha.a);
#else
    float4 outColor = UniversalFragmentWrappedDiffuse(data, diffuseAlpha.rgb, specularSmoothness, specularSmoothness.a, emission, backscatter, diffuseAlpha.a, WrapMultiplier, WrapOffset);
#endif

    return float4(outColor.rgb, 1.0f);
}

#endif // AVA2_LIT_FORWARD_PASS
