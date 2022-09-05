Shader "Microsoft/Mesh Avatars/Ava2/Blit/DiffuseMask"
{
    Properties
    {
        _BlitTex("Blit Texture", any) = "" {}
        _Color("Blend Color", Color) = (1,1,1,1)

        [Space]
        _MaskTex("Color Mask", any) = "" {}
        _PrimaryColor("Primary Color (R)", Color) = (1,1,1,1)
        _SecondaryColor("Secondary Color (G)", Color) = (1,1,1,1)
        _TertiaryColor("Tertiary Color (B)", Color) = (1,1,1,1)
        _QuaternaryColor("Quaternary Color (A)", Color) = (1,1,1,1)
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
                #pragma fragment mask_frag
                #pragma target 2.0

                #define BLIT_MASK_BLEND
                // #define _ DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                TEXTURE2D(_MaskTex);
                SAMPLER(sampler_MaskTex);
                half4 _Color;
                half4 _PrimaryColor;
                half4 _SecondaryColor;
                half4 _TertiaryColor;
                half4 _QuaternaryColor;

                #include "../Includes/HLSL/Ava2BlitShader.hlsl"
                #include "../Includes/HLSL/Ava2CommonLighting.hlsl"

                half4 mask_frag(v2f i) : SV_Target
                {
                    half4 color = frag(i);
                    half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.texcoord);

                    color.rgb = CalculateFullRandomColor(color, mask, _PrimaryColor, _SecondaryColor, _TertiaryColor, _QuaternaryColor);

                    return color * _Color;
                }

                ENDHLSL
            }
        }
    }
}
