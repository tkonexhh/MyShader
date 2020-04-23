Shader "Hidden/FadeAnim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Speed ("Speed", float) = 10
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            float _Speed;

            fixed4 frag(v2f i): SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                col.a = col.a * abs(sin(_Time.x * _Speed)) ;
                //col.a *= abs(_SinTime.z * _Speed);
                return col;
            }
            ENDCG
            
        }
    }
}
