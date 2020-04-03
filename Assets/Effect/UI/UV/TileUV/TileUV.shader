Shader "Hidden/TileUV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _TileSize ("TileSum", Range(10, 100)) = 10
        _HitTex ("Hit Tex", 2D) = "white" { }
        _Vector ("Vector", vector) = (1, 1, 0, 0)
    }
    SubShader
    {
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
            
            sampler2D _HitTex;
            float _TileSize;

            float4 _Vector;

            fixed4 frag(v2f i): SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float2 tempUV = float2(0, 0);
                tempUV.x += _Time.x * _Vector.x;
                tempUV.y += _Time.y * _Vector.y;
                float2 uv_Hit = frac(i.uv * float2(_TileSize, _TileSize) - tempUV);
                fixed4 col_Hit = tex2D(_HitTex, uv_Hit);

                fixed4 final = col + col_Hit;
                return final;
            }
            ENDCG
            
        }
    }
}
