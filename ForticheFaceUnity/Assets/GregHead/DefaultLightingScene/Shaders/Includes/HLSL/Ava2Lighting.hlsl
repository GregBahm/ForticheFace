
#ifndef AVA2_LIGHTING
#define AVA2_LIGHTING

//--------------------------------------------------------------------------------------------
// This file contains common functions for performing Lighting calculations.
//--------------------------------------------------------------------------------------------

#include "./Ava2CommonLighting.hlsl"

// Fades shadow based on distance to minimize shadow popping.
float FadeShadows(float3 posWorld, float attenuation)
{
    float shadowFade = GetShadowFade(posWorld);
    attenuation = saturate(attenuation + shadowFade);
    return attenuation;
}

half3 LightingWrappedDiffuse(half3 lightColor, half3 lightDir, half3 normal, half wrapMultiplier, half wrapOffset)
{
    half NdotL = saturate(dot(normal, lightDir));
    half wrap = NdotL * wrapMultiplier + wrapOffset;
    return (lightColor) * wrap;
}

// Based on UniversalFragmentBlinnPhong from Lighting.hlsl
half4 UniversalFragmentWrappedDiffuse(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half3 emission, half3 backscatter, half alpha, half wrapMultiplier, half wrapOffset)
{
    // To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders
#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    half4 shadowMask = inputData.shadowMask;
#elif !defined (LIGHTMAP_ON)
    half4 shadowMask = unity_ProbesOcclusion;
#else
    half4 shadowMask = half4(1, 1, 1, 1);
#endif

    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

#if defined(_SCREEN_SPACE_OCCLUSION)
    AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
    mainLight.color *= aoFactor.directAmbientOcclusion;
    inputData.bakedGI *= aoFactor.indirectAmbientOcclusion;
#endif

    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    half attenuation = (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
    half3 attenuatedLightColor = mainLight.color * attenuation;
    half3 attenuatedBackScatter = backscatter.rgb * attenuation;
    half3 diffuseColor = inputData.bakedGI + attenuatedBackScatter + LightingWrappedDiffuse(attenuatedLightColor, mainLight.direction, inputData.normalWS, wrapMultiplier, wrapOffset);
    half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);

#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
#if defined(_SCREEN_SPACE_OCCLUSION)
        light.color *= aoFactor.directAmbientOcclusion;
#endif
        half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        diffuseColor += attenuatedBackScatter + LightingWrappedDiffuse(attenuatedLightColor, light.direction, inputData.normalWS, wrapMultiplier, wrapOffset);
        specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
    }
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    diffuseColor += inputData.vertexLighting;
#endif

    half3 finalColor = diffuseColor * diffuse + emission;

#if defined(SPEC_GLOSS_MAP) || defined(_SPECULAR_COLOR)
#if defined(UNITY_COLORSPACE_GAMMA) || defined(DISABLE_LINEAR_HACKS)
    finalColor += specularColor;
#else
    // FIXME: We shouldn't be doing this.
    finalColor = SRGBToLinear(LinearToSRGB(finalColor) + LinearToSRGB(specularColor));
#endif
#endif

    return half4(finalColor, alpha);
}

#endif // AVA2_LIGHTING
