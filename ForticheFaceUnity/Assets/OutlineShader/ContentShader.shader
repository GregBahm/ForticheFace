Shader "Unlit/ContentShader"
{
	Properties
	{
		_XWidth("X Width", Range(0,1)) = 0
		_YWidth("Y Width", Range(0,1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float _XWidth;
			float _YWidth;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float xDist = abs(i.uv.x - .5) * 2;
				float yDist = abs(i.uv.y - .5) * 2;
				float xLine = xDist > _XWidth;
				float yLine = yDist > _YWidth;
				return xLine + yLine;
				return float4(i.uv, 0, 1);

			}
			ENDCG
		}
	}
}
