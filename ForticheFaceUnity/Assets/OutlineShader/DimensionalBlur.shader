Shader "OutlineShader/DimensionalBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float2 _UvKey;

			fixed4 frag(v2f i) : SV_Target
			{
				float4 ret = 0;
				const int steps = 4;

				for (int step = -steps; step <= steps; step++)
				{
					float2 uvOffset = (float2(1,1) / _ScreenParams.xy) * step  * _UvKey;// _ScreenParams.zw * step * _UvKey;
					float4 stepSample = tex2D(_MainTex, i.uv + uvOffset);
					ret += stepSample;
				}
				return ret / (steps * 2 + 1);
			}
			ENDCG
		}
	}
}
