Shader "Microsoft/Mesh Avatars/Ava2/Draw/TransparentLit"
{
    Properties
    {
        _Cube("Reflection Map", Cube) = "" {}
        _Color("Color", Color) = (1,1,1,1)
        _SpecColor("Spec Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(0.1, 10.0)) = 3.0
        _ShininessViewDir("Shininess View Dir", Range(0.1, 10.0)) = 1.75
        _BrightnessViewDir("Brightness View Dir", Range(0.0, 1.0)) = 0.5
    }

    // URP
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalRenderPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Blend One One
        ZWrite Off

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma vertex TransparentLitPassVertex
            #pragma fragment TransparentLitPassFragment
            
            #pragma multi_compile_instancing
            #pragma multi_compile_local_vertex _ AVATAR_GPU_SKINNING

            // TODO: Normalize on the defines we use here.
            #define CUSTOM_COLOR
            #define SPEC_GLOSS_MAP
            #define ENABLE_SPECULAR_CUBE
            // #define DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks
            
            #include "../Includes/HLSL/Ava2TransparentLitInput.hlsl"
            #include "../Includes/HLSL/Ava2TransparentLitForwardPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment
            
            #pragma multi_compile_instancing
            #pragma multi_compile_local_vertex _ AVATAR_GPU_SKINNING

            #include "../Includes/HLSL/Ava2TransparentLitInput.hlsl"
            #include "../Includes/HLSL/Ava2DepthNormals.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma multi_compile_instancing
            #pragma multi_compile_local_vertex _ AVATAR_GPU_SKINNING

            #include "../Includes/HLSL/Ava2TransparentLitInput.hlsl"
            #include "../Includes/HLSL/Ava2DepthOnly.hlsl"
            ENDHLSL
        }
    }
}
