Shader "Unlit/HeadShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Reflect("Reflect", 2D) = "white" {}
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
                float3 norm : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 norm : NORMAL;
                float3 vertForReflection : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _Reflect;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.norm = v.norm;
                o.vertForReflection = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float2 GetSphericalUvs(float3 norm)
            {
              float u = .5 + atan2(norm.x, norm.z) / -6.28;
              float v = .5 - asin(norm.y) / -3.14;
              return float2(u, v);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 sphereUvs = GetSphericalUvs(normalize(i.vertForReflection));
                fixed4 reflect = tex2D(_Reflect, sphereUvs);
                return col;
                return reflect;
                return float4(sphereUvs.x, sphereUvs.y, 0, 1);
                return col + reflect;
            }
            ENDCG
        }
    }
}
