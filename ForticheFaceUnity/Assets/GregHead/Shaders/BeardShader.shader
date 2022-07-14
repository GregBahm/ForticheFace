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
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
        LOD 100

        Pass // Base
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
          #pragma multi_compile_fwdbase

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
                SHADOW_COORDS(3)
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _ShineColor;
            float _SpecRamp;
            sampler2D _BeardAlpha;
            float _BeardBaseAlpha;
            fixed4 _BeardUndercolor;

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
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
              fixed shadow = SHADOW_ATTENUATION(i);
                float3 viewDir = normalize(i.viewDir);
                float3 norm = normalize(i.normal);

                float3 lightReflect = reflect(-_WorldSpaceLightPos0.xyz, norm);
                float theDot = dot(lightReflect, viewDir);
                float shine = saturate(theDot);

                shine = pow(shine, _SpecRamp);
                shine = saturate(shine * 3);
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed beardAlpha = tex2D(_BeardAlpha, i.uv);
                col = lerp(col, _BeardUndercolor, beardAlpha * _BeardBaseAlpha);
                col += shine * _ShineColor * shadow;
                return col;
            }
            ENDCG
        }

        Pass // Beard
        {

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM

            #pragma vertex vert
            #pragma geometry geo
            #pragma fragment frag
            #pragma target 4.5
            #pragma multi_compile_fwdbase

          #include "UnityCG.cginc"
          #include "UnityLightingCommon.cginc"
          #include "AutoLight.cginc"

            #define SliceCount 16
            float _Depth;
            sampler2D _MainTex;
            sampler2D _BeardAlpha;
            sampler2D _BeardNoise;
            float _BeardBaseAlpha;
            fixed4 _BeardShineColor;
            fixed4 _BeardHighColor;
            fixed4 _BeardLowColor;
            float _BeardSpecRamp;
            float _BeardTangenting;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2g
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldNormal : TEXCOORD2;
                float3 viewDir : TEXCOORD1;
            };

            struct g2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float dist : TEXCOORD3;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                SHADOW_COORDS(4)
            };

            v2g vert(appdata v)
            {
                v2g o;
                o.uv = v.uv;
                o.vertex = v.vertex;
                float3 tangent = float3(0, -1, 0);
                o.normal = lerp(v.normal, tangent, _BeardTangenting);
                o.worldNormal = mul(unity_ObjectToWorld, v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            void ApplyToTristream(v2g p[3], inout TriangleStream<g2f> triStream, float dist, float offset)
            {
                float3 vertOffset = p[0].normal * offset;
                g2f o;
                o.normal = p[0].normal;
                o.dist = dist;
                o.uv = p[0].uv;
                o.viewDir = p[0].viewDir;
                o.worldNormal = p[0].worldNormal;
                o.pos = UnityObjectToClipPos(p[0].vertex + float4(vertOffset, 0));
                TRANSFER_SHADOW(o)
                triStream.Append(o);

                vertOffset = p[1].normal * offset;
                o.normal = p[1].normal;
                o.uv = p[1].uv;
                o.viewDir = p[1].viewDir;
                o.worldNormal = p[1].worldNormal;
                o.pos = UnityObjectToClipPos(p[1].vertex + float4(vertOffset, 0));
                TRANSFER_SHADOW(o)
                triStream.Append(o);

                vertOffset = p[2].normal * offset;
                o.normal = p[2].normal;
                o.uv = p[2].uv;
                o.viewDir = p[2].viewDir;
                o.worldNormal = p[2].worldNormal;
                o.pos = UnityObjectToClipPos(p[2].vertex + float4(vertOffset, 0));
                TRANSFER_SHADOW(o)
                triStream.Append(o);
            }

            [maxvertexcount(3 * SliceCount)]
            void geo(triangle v2g p[3], inout TriangleStream<g2f> triStream)
            {
                for (int i = 0; i < SliceCount; i++)
                {
                    float dist = (float)i / SliceCount;
                    float offset = i * _Depth;
                    ApplyToTristream(p, triStream, dist, offset);
                    triStream.RestartStrip();
                }
            }

            float4 frag(g2f i) : SV_Target
            {
                float4 baseCol = tex2D(_MainTex, i.uv);
                float shade = (baseCol.x + baseCol.y + baseCol.z) * .333;
                shade = pow(shade, 2);
                float beardAlpha = tex2D(_BeardAlpha, i.uv).x;
                float beardNoise = tex2D(_BeardNoise, i.uv * 4).x;
                beardNoise = pow(beardNoise, 4) * 2;
                beardAlpha *= beardNoise;
                float lengthAlpha = 1 - pow(i.dist, .5);
                beardAlpha *= lengthAlpha;
                float3 beardColor = lerp(_BeardLowColor, _BeardHighColor, shade);


                float3 viewDir = normalize(i.viewDir);
                float3 norm = normalize(i.worldNormal);

                float3 lightReflect = reflect(-_WorldSpaceLightPos0.xyz, norm);
                float theDot = dot(lightReflect, viewDir);
                float shine = saturate(theDot);

                half shadow = SHADOW_ATTENUATION(i);
                shine = pow(shine, _BeardSpecRamp);
                shine = saturate(shine * 3);
                shine *= shadow;
                beardColor += shine * _BeardShineColor.xyz;

                return float4(beardColor, _BeardBaseAlpha * beardAlpha);
            }
            ENDCG
        }

        Pass // Shadow Caster
        {
            Tags {"LightMode" = "ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
