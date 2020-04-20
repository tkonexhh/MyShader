﻿Shader "Hidden/UVSlider"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Speed ("Speed", float) = 0.2


        //MASK SUPPORT ADD
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15
        //MASK SUPPORT END
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }

        //MASK SUPPORT ADD
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        ColorMask [_ColorMask]
        //MASK SUPPORT END

        // No culling or depth
        Cull Back
        ZWrite Off
        // ZTest Always

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
            float _Speed;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);//v.uv;
                return o;
            }

            

            fixed4 frag(v2f i): SV_Target
            {
                float2 uv = i.uv;
                uv.x += -_Time.x * _Speed ;
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
            
        }
    }
}
