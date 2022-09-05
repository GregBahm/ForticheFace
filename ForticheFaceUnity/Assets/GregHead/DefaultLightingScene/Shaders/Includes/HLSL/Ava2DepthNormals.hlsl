#ifndef AVA2_DEPTHNORMALS
#define AVA2_DEPTHNORMALS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "./Ava2Skinning.hlsl"

struct Attributes
{
    float4 positionOS     : POSITION;
    float4 tangentOS      : TANGENT;
    float3 normal       : NORMAL;

#ifdef AVATAR_GPU_SKINNING
    float4 boneWeights01 : TEXCOORD1;
    float4 boneWeights23 : TEXCOORD2;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float3 normalWS     : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthNormalsVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

#ifdef AVATAR_GPU_SKINNING
    float3 positionWS;
    ApplySkinning(input.positionOS.xyz, input.normal, input.boneWeights01, input.boneWeights23, positionWS, output.normalWS);
    output.positionCS = TransformObjectToHClip(positionWS);
#else
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
#endif

    return output;
}

float4 DepthNormalsFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    return float4(PackNormalOctRectEncode(TransformWorldToViewDir(input.normalWS, true)), 0.0, 0.0);
}

#endif // AVA2_DEPTHNORMALS
