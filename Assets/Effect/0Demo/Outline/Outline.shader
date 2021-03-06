﻿Shader "Unlit/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Outline ("Outline", float) = 0.1
        _OutlineColor ("Outline color", color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
            
        }


        Pass
        {
            Cull Front
            ZWrite Off
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float4 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
            };

            float4 _OutlineColor;
            float _Outline;

            float4 GetScaleVertex(float4 vertex)
            {

                float4x4 scaleMatrix;
                scaleMatrix[0][0] = 1 + _Outline;
                scaleMatrix[0][1] = 0;
                scaleMatrix[0][2] = 0;
                scaleMatrix[0][3] = 0;
                scaleMatrix[1][0] = 0;
                scaleMatrix[1][1] = 1 + _Outline;;
                scaleMatrix[1][2] = 0;
                scaleMatrix[1][3] = 0;
                scaleMatrix[2][0] = 0;
                scaleMatrix[2][1] = 0;
                scaleMatrix[2][2] = 1 + _Outline;;
                scaleMatrix[2][3] = 0;
                scaleMatrix[3][0] = 0;
                scaleMatrix[3][1] = 0;
                scaleMatrix[3][2] = 0;
                scaleMatrix[3][3] = 0;

                return  mul(scaleMatrix, vertex);
            }

            v2f vert(appdata v)
            {
                v2f o;
                //float4 vertex = float4(v.vertex.xyz + v.normal * _Outline * 0.1, 1);
                float4 vertex = GetScaleVertex(v.vertex);
                o.vertex = UnityObjectToClipPos(vertex);
                //o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
            
        }
    }
}
