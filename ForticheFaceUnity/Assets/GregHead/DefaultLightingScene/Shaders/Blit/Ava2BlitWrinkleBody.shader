Shader "Microsoft/Mesh Avatars/Ava2/Blit/WrinkleBodyBlit"
{
    Properties
    {
        _BlitTex("Blit Texture", 2D) = "bump" {}
        _BodyWrinkleMap("Body Wrinkle Texture", 2D) = "bump" {}
        _WrinkleIntensity("Body Wrinkle Intensity", Float) = 0.0
    }

    Category
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
        Blend Off
        Cull Off Lighting Off ZWrite Off

        SubShader
        {
            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment normal_frag
                #pragma target 2.0

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "../Includes/HLSL/Ava2BlitShader.hlsl"

                TEXTURE2D(_BodyWrinkleMap);
                SAMPLER(sampler_BodyWrinkleMap);
                float4 _BodyWrinkleMap_ST;
                float _WrinkleIntensity;

                float4 normal_frag(v2f i) : SV_Target
                {
                    ClampToRegion(i.texcoord);
                    return NormalMapLerp(_BlitTex, sampler_BlitTex, _BodyWrinkleMap, sampler_BodyWrinkleMap, _WrinkleIntensity, i.texcoord);
                }

                ENDHLSL
            }
        }
    }
}
