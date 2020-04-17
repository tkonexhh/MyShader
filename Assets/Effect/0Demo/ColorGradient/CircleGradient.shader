Shader "Unlit/CircleGradient"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Point ("Point", vector) = (0, 0, 0, 0)
        _Radius ("Radius", Range(0, 1)) = 0.2
        _Fearher ("Feather", Range(0.001, 0.9)) = 0.02
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };

            float4 _Color;
            float4 _Point;
            float _Radius;
            float _Fearher;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = _Color;//= tex2D(_MainTex, i.uv);


                float circle = pow(i.uv.x - _Point.x, 2) + pow(i.uv.y - _Point.y, 2);

                if (circle < pow(_Radius, 2))
                {
                    col.a = smoothstep(_Radius, _Radius - _Fearher, circle) * abs(_SinTime.w);
                }
                else
                {
                    col.a = 0;
                }

                return col;
            }
            ENDCG
            
        }
    }
}
