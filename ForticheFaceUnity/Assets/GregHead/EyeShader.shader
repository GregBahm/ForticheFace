Shader "Unlit/EyeShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Shadow("Shadow", Color) = (0,0,0,0)
        _Top("Top", Range(-0.1, 0.1)) = 0
        _TopScale("Top Scale", Float) = 0
        _Bottom("Bottom", Range(-0.1, 0.1)) = 0
        _BottomScale("Bottom Scale", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float3 objSpace : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float _Top;
            float _TopScale;
            float _Bottom;
            float _BottomScale;
            sampler2D _MainTex;
            fixed4 _Shadow;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.objSpace = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float top = (i.objSpace.y - _Top) * _TopScale;
                float bottom = (i.objSpace.y - _Bottom) * _BottomScale;
                float shadow = min(top, bottom);
                shadow = saturate(shadow);
                fixed4 col = tex2D(_MainTex, i.uv);
                col = lerp(col * _Shadow, col, shadow);
                return col;
            }
            ENDCG
        }
    }
}
