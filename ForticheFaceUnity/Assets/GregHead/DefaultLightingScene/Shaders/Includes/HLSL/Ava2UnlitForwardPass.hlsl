#ifndef AVA2_UNLIT_FORWARD_PASS
#define AVA2_UNLIT_FORWARD_PASS

//--------------------------------------------------------------------------------------------
// This file contains the Vertex and Fragment shader for an Unlit avatar.
//--------------------------------------------------------------------------------------------

#include "./Ava2Skinning.hlsl"

struct Attributes 
{
    float4 positionOS : POSITION;
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
    float2 uv : TEXCOORD1;

    UNITY_VERTEX_OUTPUT_STEREO
};

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

Varyings UnlitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

#ifdef AVATAR_GPU_SKINNING
    float3 positionWS;
    ApplySkinning(input.positionOS.xyz, input.boneWeights01, input.boneWeights23, positionWS);
    output.positionCS = TransformWorldToHClip(positionWS);
#else
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
#endif

    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    return output;
}

half4 UnlitPassFragment(Varyings input) : SV_Target
{
    // FIXME: Some constant scalars to compensate for some things.
#if defined(DISABLE_LINEAR_HACKS)
    const float DiffuseStrength = 1;
#else
    const float DiffuseStrength = 2;
#endif

    return SampleDiffuse(input.uv, DiffuseStrength);
}

#endif // AVA2_UNLIT_FORWARD_PASS