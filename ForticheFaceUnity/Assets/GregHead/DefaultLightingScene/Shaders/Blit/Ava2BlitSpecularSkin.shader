Shader "Microsoft/Mesh Avatars/Ava2/Blit/SpecularSkin"
{
    Properties
    {
        _BlitTex("Blit Texture", any) = "" {}
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
                #pragma fragment frag
                #pragma target 2.0

                // #define _ DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "../Includes/HLSL/Ava2BlitShader.hlsl"

                ENDHLSL
            }
        }
    }
}
