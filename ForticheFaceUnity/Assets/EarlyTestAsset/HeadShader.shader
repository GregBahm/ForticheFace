Shader "Unlit/HeadShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Reflect("Reflect", 2D) = "white" {}
        _ShineColor("Shine Color", Color) = (1,1,1,1)
        _ShineColorB("Shine Color B", Color) = (1,1,1,1)
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
                float3 worldNorm : NORMAL;
                float3 worldView : VIEWDIR;
            };

            sampler2D _MainTex;
            sampler2D _Reflect;
            float4 _ShineColor;
            float4 _ShineColorB;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNorm = mul(unity_ObjectToWorld, v.norm);
                o.worldView = WorldSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.worldNorm = normalize(i.worldNorm);
                i.worldView = normalize(i.worldView);
                float3 lightAngle = normalize(i.worldView + _WorldSpaceLightPos0.xyz);
                float shine = dot(lightAngle, i.worldNorm);

                float wideShine = shine - .75;
                wideShine = pow(saturate(wideShine), .5) * 2;
                wideShine = saturate(pow(wideShine, 10));
                float smallShine = pow(saturate(shine), 1000);
                smallShine = saturate(smallShine * 3);

                fixed4 col = tex2D(_MainTex, i.uv);
                col = lerp(col, _ShineColor * col, wideShine * _ShineColor.a);
                col = lerp(col, _ShineColorB, smallShine);
                return col;
            }
            ENDCG
        }
    }
}
