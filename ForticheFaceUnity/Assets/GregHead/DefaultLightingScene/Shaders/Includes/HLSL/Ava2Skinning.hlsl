#ifndef AVA2_SKINNING
#define AVA2_SKINNING

#ifdef AVATAR_GPU_SKINNING

float3x3 Inverse(float3x3 transform)
{
    float3x3 inverted3x3;
    inverted3x3[0] = transform[1].yzx * transform[2].zxy - transform[1].zxy * transform[2].yzx;
    inverted3x3[1] = transform[0].zxy * transform[2].yzx - transform[0].yzx * transform[2].zxy;
    inverted3x3[2] = transform[0].yzx * transform[1].zxy - transform[0].zxy * transform[1].yzx;
    
    float det = dot(transform[0].xyz, inverted3x3[0]);
    inverted3x3 = transpose(inverted3x3);
    inverted3x3 *= rcp(det);
    return inverted3x3;
}

float4x4 ComputeSkinningMatrix(float4 boneWeights01, float4 boneWeights23)
{
    const float4x4 skinningMatrix =
        mul(mul(_BoneMatrices[boneWeights01.x], _BindPoses[boneWeights01.x]), boneWeights01.y) +
        mul(mul(_BoneMatrices[boneWeights01.z], _BindPoses[boneWeights01.z]), boneWeights01.w) +
        mul(mul(_BoneMatrices[boneWeights23.x], _BindPoses[boneWeights23.x]), boneWeights23.y) +
        mul(mul(_BoneMatrices[boneWeights23.z], _BindPoses[boneWeights23.z]), boneWeights23.w);

    return skinningMatrix;
}

void ApplySkinning(float3 positionOS, float4 boneWeights01, float4 boneWeights23, out float3 positionWS)
{
    const float4x4 skinningMatrix = ComputeSkinningMatrix(boneWeights01, boneWeights23);
    positionWS = mul(skinningMatrix, float4(positionOS, 1.0)).xyz;
}

void ApplySkinning(float3 positionOS, float3 normalOS, float4 boneWeights01, float4 boneWeights23, out float3 positionWS, out float3 normalWS)
{
    const float4x4 skinningMatrix = ComputeSkinningMatrix(boneWeights01, boneWeights23);
    positionWS = mul(skinningMatrix, float4(positionOS, 1.0)).xyz;
    normalWS = normalize(mul(transpose(Inverse((float3x3)skinningMatrix)), normalOS));
}

#endif // AVATAR_GPU_SKINNING
#endif // AVA2_SKINNING
