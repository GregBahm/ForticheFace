#ifndef AVA2_DEPTHONLY
#define AVA2_DEPTHONLY

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "./Ava2Skinning.hlsl"

struct Attributes
{
    float4 position     : POSITION;

#ifdef AVATAR_GPU_SKINNING
    float4 boneWeights01 : TEXCOORD1;
    float4 boneWeights23 : TEXCOORD2;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

#ifdef AVATAR_GPU_SKINNING
    float3 positionWS;
    ApplySkinning(input.position.xyz, input.boneWeights01, input.boneWeights23, positionWS);
    output.positionCS = TransformWorldToHClip(positionWS);
#else
    output.positionCS = TransformObjectToHClip(input.position.xyz);
#endif
    
    return output;
}

half4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    return 0;
}

#endif // AVA2_DEPTHONLY
