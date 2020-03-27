Shader "Unlit/ScreenColour"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _TileSize ("Tile Size", Range(0, 100)) = 10
        _EffectTex ("Effect Tex", 2D) = "white" { }
        _Greylvl ("Grry Lvl", Range(0, 16)) = 16
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _DarkColor ("Dark Color", Color) = (0, 0, 0, 1)
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
            sampler2D _EffectTex;
            float _Greylvl;

            float4 _LightColor;
            float4 _DarkColor;

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
                // float2 tileSum = _ScreenParams / _TileSize;
                // float2 uv_Screen = round(i.uv * tileSum) / tileSum;
                // fixed4 col_Screen = tex2D(_MainTex, uv_Screen);

                // fixed grey = dot(col_Screen.rgb, float3(0.299, 0.587, 0.114));
                // if (_Greylvl > 0)
                // {
                    //     grey = round(grey * _Greylvl) / _Greylvl;
                    // }

                    // float2 uv_Effect = frac(i.uv * tileSum);
                    // fixed4 col_Effect = tex2D(_EffectTex, uv_Effect);
                    // sample the texture
                    fixed4 col = tex2D(_MainTex, i.uv);
                    float grey = dot(col.rgb, float3(0.299, 0.587, 0.114));
                    
                    

                    col = lerp(_LightColor, _DarkColor, grey);
                    // apply fog
                    UNITY_APPLY_FOG(i.fogCoord, col);
                    return col;
                }
                ENDCG
                
            }
        }
    }
