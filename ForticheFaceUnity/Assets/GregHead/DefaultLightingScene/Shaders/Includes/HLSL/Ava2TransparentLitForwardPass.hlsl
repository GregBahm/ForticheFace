#ifndef AVA2_TRANSPARENT_LIT_FORWARD_PASS
#define AVA2_TRANSPARENT_LIT_FORWARD_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "./Ava2Skinning.hlsl"

//--------------------------------------------------------------------------------------------
// This file contains the Vertex and Fragment shader for a Transparent Lit avatar.
//--------------------------------------------------------------------------------------------

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
    half3 viewDirectionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
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
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

Varyings TransparentLitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

#ifdef AVATAR_GPU_SKINNING
    ApplySkinning(input.positionOS.xyz, input.normalOS, input.boneWeights01, input.boneWeights23, output.positionWS, output.normalWS);
    output.positionCS = TransformWorldToHClip(output.positionWS);
#else
    output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.normalWS = normalize(TransformObjectToWorldNormal(input.normalOS));
#endif

    output.viewDirectionWS = normalize(GetWorldSpaceViewDir(output.positionWS));

    return output;
}

half4 TransparentLitPassFragment(Varyings input) : SV_Target
{
#ifdef ENABLE_SPECULAR_CUBE
    //CubeMap
    float3 normalDirection = normalize(input.normalWS);
    float3 reflectedDir = reflect(input.viewDirectionWS, normalDirection);
    half3 viewDirection = normalize(GetWorldSpaceViewDir(input.positionWS));

    float4 diffuse = SAMPLE_TEXTURECUBE(_Cube, sampler_Cube, reflectedDir);

#if defined(UNITY_COLORSPACE_GAMMA) || defined(DISABLE_LINEAR_HACKS)
    diffuse *= _Color;
#else
    // FIXME: convert _Color back to gamma space as a workaround to match the look as the gamma space version
    diffuse.rgb *= LinearToSRGB(_Color.rgb);
#endif

    half3 specularDynamic = LightingSpecular(_MainLightColor.rgb, _MainLightPosition.xyz, normalDirection, viewDirection, _SpecColor, _Shininess * 48) * _MainLightColor.r;

    // We do a fixed angle specular highlight to make sure it's always visible by passing in an empty light direction.
    half3 specularFixed = LightingSpecular(half3(1, 1, 1), half3(0, 0, 0), normalDirection, viewDirection, _SpecColor, _Shininess * 175 * _ShininessViewDir) * 0.25 * _BrightnessViewDir;

    return float4(diffuse.rgb + specularDynamic + specularFixed, 0);
#else
    return float4(1, 1, 0, 0);
#endif
}

#endif // AVA2_TRANSPARENT_LIT_FORWARD_PASS

