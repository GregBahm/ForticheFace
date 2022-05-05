Shader "Unlit/EyeBakeTest"
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 base = tex2D(_Base, i.uv);
                fixed4 lookDown = tex2D(_LookDown, i.uv);
                fixed4 lookUp = tex2D(_LookUp, i.uv);
                fixed4 lookLeft = tex2D(_LookLeft, i.uv);
                fixed4 lookRight = tex2D(_LookRight, i.uv);
                
                float downLerp = max(-_UpDown, 0);
                float upLerp = max(_UpDown, 0);
                float leftLerp = max(-_LeftRight, 0);
                float rightLerp = max(_LeftRight, 0);
                fixed4 col = lerp(base, lookDown, downLerp);
                col = lerp(col, lookUp, upLerp);
                col = lerp(col, lookLeft, leftLerp);
                col = lerp(col, lookRight, rightLerp);

                return col;
            }
            ENDCG
        }
    }
}
