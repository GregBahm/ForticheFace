Shader "Unlit/BeardShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _BeardAlpha("Beard Alpha", 2D) = "white" {}
        _BeardNoise("Beard Noise", 2D) = "white" {}
        _BeardBaseAlpha("Beard Base Alpha", Range(0, 1)) = 1
        _BeardTangenting("Beard Tangenting", Range(0, 1)) = 1
        _BeardHighColor("Beard High Color", Color) = (1,1,1,1)
        _BeardLowColor("Beard Low Color", Color) = (1,1,1,1)
        _ShineColor("Shine Color", Color) = (1,1,1,1)
        _BeardShineColor("Beard Shine Color", Color) = (1,1,1,1)
        _BeardUndercolor("Beard Undercolor", Color) = (1,1,1,1)
        _SpecRamp("Spec Ramp", Float) = 50
        _BeardSpecRamp("Beard Spec Ramp", Float) = 50
        _Depth("Depth", Range(0, .001)) = .0005
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass // Base
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

          #include "UnityCG.cginc"
          #include "UnityLightingCommon.cginc"
          #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _ShineColor;
            float _SpecRamp;
            sampler2D _BeardAlpha;
            float _BeardBaseAlpha;
            fixed4 _BeardUndercolor;
            
            float _Depth;
            sampler2D _BeardNoise;
            fixed4 _BeardShineColor;
            fixed4 _BeardHighColor;
            fixed4 _BeardLowColor;
            float _BeardSpecRamp;
            float _BeardTangenting;
            

            float4 AddBeard(half4 col, v2f i, float3 norm, float3 viewDir)
            {
                float4 baseCol = tex2D(_MainTex, i.uv);
                float shade = (baseCol.x + baseCol.y + baseCol.z) * .333;
                shade = pow(shade, 2);
                float beardAlpha = tex2D(_BeardAlpha, i.uv).x;
                float beardNoise = tex2D(_BeardNoise, i.uv * 4).x;
                beardNoise = pow(beardNoise, 4) * 2;
                beardAlpha *= beardNoise;
                beardAlpha *= 1;
                float3 beardColor = lerp(_BeardLowColor, _BeardHighColor, shade);

                float3 lightReflect = reflect(-_WorldSpaceLightPos0.xyz, norm);
                float theDot = dot(lightReflect, viewDir);
                float shine = saturate(theDot);

                shine = pow(shine, _BeardSpecRamp);
                shine = saturate(shine * 3);
                beardColor += shine * _BeardShineColor.xyz;
                col = lerp(col, float4(beardColor, 1), beardAlpha);
                return col;
             }

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
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

                shine = pow(shine, _SpecRamp);
                shine = saturate(shine * 3);
                float4 col = tex2D(_MainTex, i.uv);
                fixed beardAlpha = tex2D(_BeardAlpha, i.uv);
                col = lerp(col, _BeardUndercolor, beardAlpha * _BeardBaseAlpha);
                col = AddBeard(col, i, norm, viewDir);
                col += shine * _ShineColor;
                return col;
            }
            ENDCG
        }
    }
}
