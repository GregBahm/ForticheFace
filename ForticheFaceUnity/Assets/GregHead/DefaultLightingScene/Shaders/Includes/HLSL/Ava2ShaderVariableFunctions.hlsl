#ifndef AVA2_SHADER_VARIABLE_FUNCTIONS
#define AVA2_SHADER_VARIABLE_FUNCTIONS
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl" // for GetOddNegativeScale()

VertexPositionInputs GetVertexPositionInputs(float3 positionWS, float4 positionCS)
{
    VertexPositionInputs input;
    input.positionWS = positionWS;
    input.positionCS = positionCS;
    input.positionVS = TransformWorldToView(input.positionWS);

    float4 ndc = input.positionCS * 0.5f;
    input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    input.positionNDC.zw = input.positionCS.zw;

    return input;
}

void ComputeTangents(float3 normalWS, float4 tangentOS, out real3 tangentWS, out real3 bitangentWS)
{
    // mikkts space compliant. only normalize when extracting normal at frag.
    real sign = real(tangentOS.w) * GetOddNegativeScale();
    tangentWS = real3(TransformObjectToWorldDir(tangentOS.xyz));
    bitangentWS = real3(cross(normalWS, float3(tangentWS))) * sign;
}

#endif // AVA2_SHADER_VARIABLE_FUNCTIONS