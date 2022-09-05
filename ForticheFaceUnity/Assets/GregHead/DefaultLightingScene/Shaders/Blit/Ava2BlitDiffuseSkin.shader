Shader "Microsoft/Mesh Avatars/Ava2/Blit/DiffuseSkin"
{
    Properties
    {
        _BlitTex("Blit Texture", any) = "" {}
        _Color("Blend Color", Color) = (1,1,1,1)
        _BlendMaskTex("Blend Color Mask", 2D) = "white" {}
    }

    Category
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }
        
        Blend Off
        Cull Off Lighting Off ZWrite Off

        SubShader
        {
            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment blend_frag
                #pragma target 2.0
                
                // #define _ DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "../Includes/HLSL/Ava2BlitShader.hlsl"

                half4 _Color;
                TEXTURE2D(_BlendMaskTex);
                SAMPLER(sampler_BlendMaskTex);

                half4 blend_frag(v2f i) : SV_Target
                {
                    half4 color = frag(i);
                    half3 blended = color.rgb * _Color.rgb;
                    color.rgb = lerp(color.rgb, blended, SAMPLE_TEXTURE2D(_BlendMaskTex, sampler_BlendMaskTex, i.texcoord).rgb);
                    return color;
                }

                ENDHLSL
            }
        }
    }
}
