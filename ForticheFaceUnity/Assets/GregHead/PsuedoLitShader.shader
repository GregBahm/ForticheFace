Shader "Unlit/PsuedoLitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShineColor("Shine Color", Color) = (1,1,1,1)
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            fixed4 _ShineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = mul(unity_ObjectToWorld, v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 viewDir = normalize(i.viewDir);
                float3 norm = normalize(i.normal);

                float3 lightReflect = reflect(-_WorldSpaceLightPos0.xyz, norm);
                float theDot = dot(lightReflect, viewDir);
                float shine = saturate(theDot);
                shine = pow(shine, 50);
                shine = saturate(shine * 3);
                fixed4 col = tex2D(_MainTex, i.uv);
                col += shine * _ShineColor;
                return col;
            }
            ENDCG
        }
    }
}
