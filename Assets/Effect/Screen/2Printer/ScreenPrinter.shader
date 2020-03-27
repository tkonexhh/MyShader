Shader "Unlit/ScreenPrinter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _TileSize ("Tile Size", Range(0, 40)) = 10
        _EffTex ("Effect Tex", 2D) = "white" { }
        _GreyLevel ("Grey Lvl", Range(0, 16)) = 0
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
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _TileSize;
            sampler2D _EffTex;
            float _GreyLevel;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                float2 tileSum = _ScreenParams / _TileSize;
                float2 uv_Screen = ceil(i.uv * tileSum) / tileSum;
                fixed4 col_Screen = tex2D(_MainTex, uv_Screen);

                float2 uv_Effect = frac(i.uv * tileSum) ;
                fixed4 col_Effect = tex2D(_EffTex, uv_Effect);
                // sample the texture
                fixed4 col = col_Screen * col_Effect.r;
                fixed grey = dot(col_Screen.rgb, float3(0.299, 0.587, 0.114));

                if (_GreyLevel > 0)
                {
                    grey = round(grey * _GreyLevel) / _GreyLevel;
                }

                if(col.a < (1 - grey))
                {
                    col = fixed4(0, 0, 0, 1);
                }
                else
                {
                    col = fixed4(1, 1, 1, 1);
                }

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
    }
}
