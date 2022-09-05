#ifndef AVA2_TRANSPARENT_LIT_INPUT
#define AVA2_TRANSPARENT_LIT_INPUT

//--------------------------------------------------------------------------------------------
// This file contains the following functionalities required for Ava2TransparentForwardPass.hlsl
//      - Constant buffer layout
//      - Textures
//      - Helper functions for sampling and applying dependent textures
//--------------------------------------------------------------------------------------------

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "./Ava2ShaderVariableFunctions.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
half4 _Color;
half4 _SpecColor;
half _Shininess;
half _ShininessViewDir;
half _BrightnessViewDir;
float4x4 _BoneMatrices[118];
float4x4 _BindPoses[118];
CBUFFER_END

TEXTURECUBE(_Cube); SAMPLER(sampler_Cube);

#endif // AVA2_TRANSPARENT_LIT_INPUT
