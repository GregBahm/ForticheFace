Shader "Microsoft/Mesh Avatars/Ava2/Blit/NormalCopy"
{
    Properties
    {
        _BlitTex("Blit Texture", 2D) = "bump" {}
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

                half4 normal_frag(v2f i) : SV_Target
                {
                    half4 color = frag(i);

                    color.rgb = 0.5 * UnpackNormal(color) + 0.5;
                    color.a = 1;

                    return color;
                }

                ENDHLSL
            }
        }
    }
}
