Shader "Microsoft/Mesh Avatars/Ava2/Blit/SpecularHead"
{
    Properties
    {
        _BlitTex("Blit Texture", any) = "" {}
        
        [Space]
        _EyeMakeup("Enable Eye Makeup", Range(0.0, 1.0)) = 0
        _EyeMakeupMaskTex("Eye Makeup Mask Texture", 2D) = "black" {}

        [Space]
        _LipMakeup("Enable Lip Makeup", Range(0.0, 1.0)) = 0
        _LipMakeupMaskTex("Lip Makeup Mask Texture", 2D) = "black" {}

        [Space]
        _CheekMakeup("Enable Cheek Makeup", Range(0.0, 1.0)) = 0
        _CheekMakeupMaskTex("Cheek Makeup Mask Texture", 2D) = "black" {}

        [Space]
        _ScalpStubble("Enable Scalp Stubble", Range(0.0, 1.0)) = 0
        _ScalpStubbleMaskTex("Scalp Stubble Mask Texture", 2D) = "black" {}

        [Space]
        _JawStubble("Enable Jaw Stubble", Range(0.0, 1.0)) = 0
        _JawStubbleMaskTex("Jaw Stubble Mask Texture", 2D) = "black" {}
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
                #pragma fragment makeup_frag
                #pragma target 2.0

                // #define _ DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "../Includes/HLSL/Ava2BlitShader.hlsl"
                #include "../Includes/HLSL/Ava2CommonLighting.hlsl"

                float _EyeMakeup;
                TEXTURE2D(_EyeMakeupMaskTex);
                SAMPLER(sampler_EyeMakeupMaskTex);
                float4 _EyeMakeupMaskTex_ST;

                float _LipMakeup;
                TEXTURE2D(_LipMakeupMaskTex);
                SAMPLER(sampler_LipMakeupMaskTex);
                float4 _LipMakeupMaskTex_ST;

                float _CheekMakeup;
                TEXTURE2D(_CheekMakeupMaskTex);
                SAMPLER(sampler_CheekMakeupMaskTex);
                float4 _CheekMakeupMaskTex_ST;

                float _ScalpStubble;
                TEXTURE2D(_ScalpStubbleMaskTex);
                SAMPLER(sampler_ScalpStubbleMaskTex);
                float4 _ScalpMakeupMaskTex_ST;

                float _JawStubble;
                TEXTURE2D(_JawStubbleMaskTex);
                SAMPLER(sampler_JawStubbleMaskTex);
                float4 _JawMakeupMaskTex_ST;

                half4 makeup_frag(v2f i) : SV_Target
                {
                    half4 color = frag(i);

                    // FIXME: We should support spec maps for makeup and stubble.
                    color.a = CalculateMakeupSpecular(_EyeMakeup, color.a, SAMPLE_TEXTURE2D(_EyeMakeupMaskTex, sampler_EyeMakeupMaskTex, i.texcoord).a);
                    color.a = CalculateMakeupSpecular(_LipMakeup, color.a, SAMPLE_TEXTURE2D(_LipMakeupMaskTex, sampler_LipMakeupMaskTex, i.texcoord).a);
                    color.a = CalculateMakeupSpecular(_CheekMakeup, color.a, SAMPLE_TEXTURE2D(_CheekMakeupMaskTex, sampler_CheekMakeupMaskTex, i.texcoord).a);
                    return color;
                }

                ENDHLSL
            }
        }
    }
}
