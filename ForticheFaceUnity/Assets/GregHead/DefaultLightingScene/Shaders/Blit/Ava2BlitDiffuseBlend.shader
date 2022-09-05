Shader "Microsoft/Mesh Avatars/Ava2/Blit/DiffuseBlend"
{
    Properties
    {
        _BlitTex("Blit Texture", any) = "" {}
        _Color("Blend Color", Color) = (1,1,1,1)
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

                half4 blend_frag(v2f i) : SV_Target
                {
                    half4 color = frag(i);
                    return color * _Color;
                }

                ENDHLSL
            }
        }
    }
}
