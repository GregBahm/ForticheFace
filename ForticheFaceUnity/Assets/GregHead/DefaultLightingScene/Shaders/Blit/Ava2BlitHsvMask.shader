Shader "Microsoft/Mesh Avatars/Ava2/Blit/HsvMask"
{
    Properties
    {
        _BlitTex("Texture", 2D) = "white" {}
        _Color("Diffuse Material Color", Color) = (0.65,0.65,0.65,1)
        _HueRange("Hue", Range(-1, 1)) = 0
        _SatRange("Saturation", Range(-1, 0)) = 0
        _BrightnessRange("Brightness", Range(-1, 1)) = 0
        _MaskTex("Mask Texture", 2D) = "black" {}
    }

    Category
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }
        Blend Off
        Cull Off Lighting Off ZWrite Off

        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment hsv_mask_frag
                #pragma target 2.0

                #define ENABLE_HSVMASKING
                // #define _ DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "../Includes/HLSL/Ava2BlitShader.hlsl"
                #include "../Includes/HLSL/Ava2CommonLighting.hlsl"

                TEXTURE2D(_MaskTex);
                SAMPLER(sampler_MaskTex);
                half4 _Color;
                float _HueRange;
                float _SatRange;
                float _BrightnessRange;

                half4 hsv_mask_frag(v2f i) : SV_Target
                {
                    half4 col = frag(i);
                    col *= _Color;
                    half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.texcoord);
                    col.rgb = CalculateHsvColor(col.rgb, _HueRange, _SatRange, _BrightnessRange, mask.r);

                    return col;
                }
                ENDHLSL
            }
        } 
    }
}
