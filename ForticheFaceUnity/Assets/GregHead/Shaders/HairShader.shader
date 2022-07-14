Shader "Unlit/HairShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShineColor("Shine Color", Color) = (1,1,1,1)
        _HairShineColor("Hair Shine Color", Color) = (1,1,1,1)
        _HairShineDir("Hair Shine Direction", Vector) = (0, 0, 0)
        _SpecRamp("Spec Ramp", Float) = 50
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
        LOD 100

        Pass
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
                float3 fromCenter : TEXCOORD2;
                SHADOW_COORDS(3)
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _ShineColor;
            fixed4 _HairShineColor;
            float3 _HairShineDir;
            float _SpecRamp;

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
                o.fromCenter = v.vertex - float3(0, .25, 0);
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

                float3 hairNorm = normalize(i.fromCenter);
                float3 hairLightReflect = reflect(normalize(_HairShineDir), hairNorm);
                float theHairDot = dot(hairLightReflect, viewDir);
                theHairDot = theHairDot;
                float aniso = abs(.55 - theHairDot);
                aniso = saturate(1 - aniso);
                aniso = pow(aniso, 5);
                aniso *= saturate(hairNorm.y + .5);

                shine = pow(shine, _SpecRamp);
                shine = saturate(shine * 3);
                fixed4 col = tex2D(_MainTex, i.uv);
                col += shine * _ShineColor * shadow;

                col += _HairShineColor * aniso;

                return col;
            }
            ENDCG
        }
        Pass
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
