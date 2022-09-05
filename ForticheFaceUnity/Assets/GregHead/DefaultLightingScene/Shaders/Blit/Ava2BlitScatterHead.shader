Shader "Microsoft/Mesh Avatars/Ava2/Blit/ScatterHead"
{
    Properties
    {
        _BlitTex("Blit Texture", any) = "" {}
        _BackColor("Blend Color", Color) = (1,1,1,1)

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
                #pragma fragment scatter_frag
                #pragma target 2.0
                
                #define BLIT_STUBBLE
                // #define _ DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "../Includes/HLSL/Ava2BlitShader.hlsl"
                #include "../Includes/HLSL/Ava2CommonLighting.hlsl"

                half4 _BackColor;

                float _ScalpStubble;
                TEXTURE2D(_ScalpStubbleMaskTex);
                SAMPLER(sampler__ScalpStubbleMaskTex);
                float4 _ScalpMakeupMaskTex_ST;

                float _JawStubble;
                TEXTURE2D(_JawStubbleMaskTex);
                SAMPLER(sampler__JawStubbleMaskTex);
                float4 _JawMakeupMaskTex_ST;

                half4 scatter_frag(v2f i) : SV_Target
                {
                    half4 color = frag(i);
                    return color.r * _BackColor;
                }

                ENDHLSL
            }
        }
    }
}
