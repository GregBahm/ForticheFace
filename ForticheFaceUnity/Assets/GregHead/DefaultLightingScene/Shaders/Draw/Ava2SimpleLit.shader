Shader "Microsoft/Mesh Avatars/Ava2/Draw/SimpleLit"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
	}
	
	// URP
	SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalRenderPipeline"
			"RenderType" = "Opaque"
		}

		Pass
		{
			Tags { "LightMode" = "UniversalForward" }

			HLSLPROGRAM
			#pragma vertex SimpleLitPassVertex
			#pragma fragment SimpleLitPassFragment

		    // -------------------------------------
		    // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_local _ _RECEIVE_SHADOWS_OFF

            #pragma multi_compile_instancing

            // -------------------------------------
            // Avatar Keywords
            #pragma multi_compile_local_vertex _ AVATAR_GPU_SKINNING

		    // TODO: Normalize on the defines we use here.
		    #define BAKED_NORMALS
            // #define DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks
            
            #include "../Includes/HLSL/Ava2SimpleLitInput.hlsl"
            #include "../Includes/HLSL/Ava2SimpleLitForwardPass.hlsl"
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

            // -------------------------------------
            // Avatar Keywords
            #pragma multi_compile_local_vertex _ AVATAR_GPU_SKINNING

            #include "../Includes/HLSL/Ava2SimpleLitInput.hlsl"
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

            // -------------------------------------
            // Avatar Keywords
            #pragma multi_compile_local_vertex _ AVATAR_GPU_SKINNING

            #include "../Includes/HLSL/Ava2SimpleLitInput.hlsl"
            #include "../Includes/HLSL/Ava2DepthOnly.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Avatar Keywords
            #pragma multi_compile_local_vertex _ AVATAR_GPU_SKINNING

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "../Includes/HLSL/Ava2SimpleLitInput.hlsl"
            #include "../Includes/HLSL/Ava2ShadowCasterPass.hlsl"
            ENDHLSL
        }
	}
}
