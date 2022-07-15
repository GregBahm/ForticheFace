Shader "Unlit/EyeShader"
{
    Properties
    {
        _Base("Base", 2D) = "white" {}
        _LookDown("Look Down", 2D) = "white" {}
        _LookUp("Look Up", 2D) = "white" {}
        _LookLeft("Look Left", 2D) = "white" {}
        _LookRight("Look Right", 2D) = "white" {}
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _Base;
            sampler2D _LookDown;
            sampler2D _LookUp;
            sampler2D _LookLeft;
            sampler2D _LookRight;

            float _UpDown;
            float _LeftRight;

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = mul(unity_ObjectToWorld, v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            float4 GetCol(float2 uv)
            {
                fixed4 base = tex2D(_Base, uv);
                fixed4 lookDown = tex2D(_LookDown, uv);
                fixed4 lookUp = tex2D(_LookUp, uv);
                fixed4 lookLeft = tex2D(_LookLeft, uv);
                fixed4 lookRight = tex2D(_LookRight, uv);

                float downLerp = max(-_UpDown, 0);
                float upLerp = max(_UpDown, 0);
                float leftLerp = max(-_LeftRight, 0);
                float rightLerp = max(_LeftRight, 0);
                float4 col = lerp(base, lookDown, downLerp);
                col = lerp(col, lookUp, upLerp);
                col = lerp(col, lookLeft, leftLerp);
                col = lerp(col, lookRight, rightLerp);

                return col;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                float3 viewDir = normalize(i.viewDir);
                float3 norm = normalize(i.normal);
                float theDot = dot(norm, viewDir);
                float shine = saturate(theDot);

                shine = pow(shine, 20);
                shine = saturate(shine * 1);

                float4 col = GetCol(i.uv);
                col += shine * col * float4(.5, .5, 0, 1);
                return col;
            }
            ENDCG
        }
    }
}
