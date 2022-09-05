Shader "Microsoft/Mesh Avatars/Ava2/Draw/Unlit"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
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
			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment

            #pragma multi_compile_instancing

            // -------------------------------------
            // Avatar Keywords
            #pragma multi_compile_local_vertex _ AVATAR_GPU_SKINNING

		    // TODO: Normalize on the defines we use here.
		    #define BAKED_NORMALS
            // #define DISABLE_LINEAR_HACKS // uncomment this to disable linear hacks
            
            #include "../Includes/HLSL/Ava2UnlitInput.hlsl"
            #include "../Includes/HLSL/Ava2UnlitForwardPass.hlsl"
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

            #include "../Includes/HLSL/Ava2UnlitInput.hlsl"
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

            #include "../Includes/HLSL/Ava2UnlitInput.hlsl"
            #include "../Includes/HLSL/Ava2DepthOnly.hlsl"
            ENDHLSL
        }
	}
}
