Shader "Custom/GradientEffect"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" { }
        _Gradient ("Gradient,x:slope,y:speed,zw:gradual", vector) = (-0.1, 5, 0.3, 0.01)
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
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
                float2 local_uv: TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.local_uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            fixed4 _Color;
            float4 _Gradient;
            float _Speed;

            fixed4 frag(v2f i): SV_Target
            {
                _Speed += _Time.x * _Gradient.y;
                fixed4 col = tex2D(_MainTex, i.uv);
                _Speed += _Gradient.x * i.local_uv.y;
                float gradient = i.local_uv.x - (_Speed % 1.5);
                gradient = gradient > 0 ?
                max(_Gradient.w - gradient, 0) / _Gradient.w:
                max(_Gradient.z + gradient, 0) / _Gradient.z;
                col.rgb = lerp(col.rgb, _Color.rgb, gradient);
                return col;
            }
            ENDCG
            
        }
    }
}
