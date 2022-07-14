Shader "Unlit/EyeLensShader"
{
    Properties
    {
    }
        SubShader
    {
        Tags { "Queue" = "Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend One One
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


            v2f vert(appdata v)
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


            fixed4 frag(v2f i) : SV_Target
            {

                float3 viewDir = normalize(i.viewDir);
                float3 norm = normalize(i.normal);
                float theDot = dot(norm, viewDir);
                float shine = saturate(theDot);

                shine = pow(shine, 500);
                shine = saturate(shine * 3);
                shine = saturate(shine);
                shine *= .2;
                return shine;
            }
            ENDCG
        }
    }
}
