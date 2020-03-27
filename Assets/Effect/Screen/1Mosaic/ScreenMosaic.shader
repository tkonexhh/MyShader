Shader "Unlit/ScreenMosaic"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _BlockTex ("BlockTex", 2D) = "white" { }
        _TileSize ("TileSize", Range(0, 100)) = 10
        _EffectChannel ("Effect Channel", Range(0, 4)) = 4
        _ColorLvl ("Color Level", Range(0, 16)) = 16
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
            sampler2D _BlockTex;
            float4 _MainTex_ST;

            float _TileSize;
            float _ColorLvl;
            float _EffectChannel;

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
                float2 uv_Mosaic = round(i.uv * tileSum) / tileSum;
                fixed4 col_Masaic = tex2D(_MainTex, uv_Mosaic);
                if (_ColorLvl > 0)
                {
                    col_Masaic = round(col_Masaic * _ColorLvl) / _ColorLvl;
                }
                

                float2 uv_Effect = frac(i.uv * tileSum + 0.5);
                //这个和取整有关系

                fixed4 col_Effect = tex2D(_BlockTex, uv_Effect);
                
                // sample the texture
                fixed4 col = col_Masaic ;//* col_Effect;
                switch(_EffectChannel)
                {
                    case 1:
                    col *= col_Effect.r;
                    break;
                    case 2:
                    col *= col_Effect.g;
                    break;
                    case 3:
                    col *= col_Effect.b;
                    break;
                    case 0:
                    col *= col_Effect.a;
                    break;
                }
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
    }
}
