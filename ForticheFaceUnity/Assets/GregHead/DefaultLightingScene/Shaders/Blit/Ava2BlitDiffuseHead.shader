Shader "Microsoft/Mesh Avatars/Ava2/Blit/DiffuseHead"
{
    Properties
    {
        _BlitTex("Blit Texture", any) = "" {}
        _Color("Blend Color", Color) = (1,1,1,1)
        _BlendMaskTex("Blend Color Mask", 2D) = "white" {}

        [Space]
        _EyeMakeup("Enable Eye Makeup", Range(0.0, 1.0)) = 0
        _EyeMakeupMaskTex("Eye Makeup Mask Texture", 2D) = "black" {}
        _PrimaryEyeMakeupColor("Eye Makeup Primary Color (R)", Color) = (1,1,1,1)
        _SecondaryEyeMakeupColor("Eye Makeup Secondary Color (G)", Color) = (1,1,1,1)

        [Space]
        _LipMakeup("Enable Lip Makeup", Range(0.0, 1.0)) = 0
        _LipMakeupMaskTex("Lip Makeup Mask Texture", 2D) = "black" {}
        _PrimaryLipMakeupColor("Lip Makeup Primary Color (R)", Color) = (1,1,1,1)
        _SecondaryLipMakeupColor("Lip Makeup Secondary Color (G)", Color) = (1,1,1,1)

        [Space]
        _CheekMakeup("Enable Cheek Makeup", Range(0.0, 1.0)) = 0
        _CheekMakeupMaskTex("Cheek Makeup Mask Texture", 2D) = "black" {}
        _PrimaryCheekMakeupColor("Cheek Makeup Primary Color (R)", Color) = (1,1,1,1)
        _SecondaryCheekMakeupColor("Cheek Makeup Secondary Color (G)", Color) = (1,1,1,1)

        [Space]
        _ScalpStubble("Enable Scalp Stubble", Range(0.0, 1.0)) = 0
        _ScalpStubbleMaskTex("Scalp Stubble Mask Texture", 2D) = "black" {}
        _ScalpStubbleColor("Scalp Stubble Color", Color) = (1,1,1,1)

        [Space]
        _JawStubble("Enable Jaw Stubble", Range(0.0, 1.0)) = 0
        _JawStubbleMaskTex("Jaw Stubble Mask Texture", 2D) = "black" {}
        _JawStubbleColor("Jaw Stubble Color", Color) = (1,1,1,1)
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

                #define BLIT_STUBBLE
                #define BLIT_MAKEUP

                // #define _ DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "../Includes/HLSL/Ava2BlitShader.hlsl"
                #include "../Includes/HLSL/Ava2CommonLighting.hlsl"

                half4 _Color;
                TEXTURE2D(_BlendMaskTex);
                SAMPLER(sampler_BlendMaskTex);

                float _EyeMakeup;
                TEXTURE2D(_EyeMakeupMaskTex);
                SAMPLER(sampler_EyeMakeupMaskTex);
                float4 _EyeMakeupMaskTex_ST;
                half4 _PrimaryEyeMakeupColor;
                half4 _SecondaryEyeMakeupColor;

                float _LipMakeup;
                TEXTURE2D(_LipMakeupMaskTex);
                SAMPLER(sampler_LipMakeupMaskTex);
                float4 _LipMakeupMaskTex_ST;
                half4 _PrimaryLipMakeupColor;
                half4 _SecondaryLipMakeupColor;

                float _CheekMakeup;
                TEXTURE2D(_CheekMakeupMaskTex);
                SAMPLER(sampler_CheekMakeupMaskTex);
                float4 _CheekMakeupMaskTex_ST;
                half4 _PrimaryCheekMakeupColor;
                half4 _SecondaryCheekMakeupColor;

                float _ScalpStubble;
                TEXTURE2D(_ScalpStubbleMaskTex);
                SAMPLER(sampler_ScalpStubbleMaskTex);
                float4 _ScalpMakeupMaskTex_ST;
                half4 _ScalpStubbleColor;

                float _JawStubble;
                TEXTURE2D(_JawStubbleMaskTex);
                SAMPLER(sampler_JawStubbleMaskTex);
                float4 _JawMakeupMaskTex_ST;
                half4 _JawStubbleColor;

                half4 makeup_frag(v2f i) : SV_Target
                {
                    half4 color = frag(i);

                    color.rgb = lerp(color.rgb, CalculateMakeupColor(color, SAMPLE_TEXTURE2D(_EyeMakeupMaskTex, sampler_EyeMakeupMaskTex, i.texcoord), _PrimaryEyeMakeupColor, _SecondaryEyeMakeupColor), _EyeMakeup);
                    color.rgb = lerp(color.rgb, CalculateMakeupColor(color, SAMPLE_TEXTURE2D(_LipMakeupMaskTex, sampler_LipMakeupMaskTex, i.texcoord), _PrimaryLipMakeupColor, _SecondaryLipMakeupColor), _LipMakeup);
                    color.rgb = lerp(color.rgb, CalculateMakeupColor(color, SAMPLE_TEXTURE2D(_CheekMakeupMaskTex, sampler_CheekMakeupMaskTex, i.texcoord), _PrimaryCheekMakeupColor, _SecondaryCheekMakeupColor), _CheekMakeup);

                    color.rgb = lerp(color.rgb, CalculateStubble(color, SAMPLE_TEXTURE2D(_ScalpStubbleMaskTex, sampler_ScalpStubbleMaskTex, i.texcoord), _ScalpStubbleColor), _ScalpStubble);
                    color.rgb = lerp(color.rgb, CalculateStubble(color, SAMPLE_TEXTURE2D(_JawStubbleMaskTex, sampler_JawStubbleMaskTex, i.texcoord), _JawStubbleColor), _JawStubble);

                    half3 blended = color.rgb * _Color.rgb;
                    color.rgb = lerp(color.rgb, blended, SAMPLE_TEXTURE2D(_BlendMaskTex, sampler_BlendMaskTex, i.texcoord).rgb);
                    return color;
                }

                ENDHLSL
            }
        }
    }
}
