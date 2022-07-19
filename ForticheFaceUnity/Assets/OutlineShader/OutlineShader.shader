Shader "OutlineShader/OutlineShader"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "black" {}
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
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
			sampler2D _FullBlurredTexture;
			float4 _OutlineColor;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 base = tex2D(_MainTex, i.uv);
				fixed4 outlineSource = tex2D(_FullBlurredTexture, i.uv);
				float alpha = 1 - abs(outlineSource.x - .5) * 2;
				alpha = pow(alpha * 2, 2);
				//float alpha = pow(outlineSource.x * 5, 5);
				alpha = saturate(alpha) - saturate(base.a);
				alpha *= 1 - i.uv.x;
                return lerp(base, _OutlineColor, saturate(alpha * _OutlineColor.a));
			}
			ENDCG
		}
	}
}
