Shader "Unlit/DitherPattern"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _TileSize ("TileSize", Range(0, 100)) = 10
        _RGBTex ("Eff Tex", 2D) = "white" { }
        _DitherLevel ("Dither Level", Range(0, 4)) = 0
        _DitherTex ("Dither Tex", 2D) = "White" { }
        _DisplayModeID ("显示模式ID", Range(0, 4)) = 0
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
            sampler2D _RGBTex;
            fixed _DitherLevel;
            sampler2D _DitherTex;
            fixed _DisplayModeID;

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
                float2 DitherSum = tileSum;
                switch(_DitherLevel)
                {
                    case 1:
                    DitherSum = _ScreenParams / (_TileSize * 2);
                    break;
                    case 2:
                    DitherSum = _ScreenParams / (_TileSize * 4);
                    break;
                    case 3:
                    DitherSum = _ScreenParams / (_TileSize * 8);
                    break;
                }

                float2 uv_Screen = round(i.uv * DitherSum) / DitherSum;
                fixed4 col_Screen = tex2D(_MainTex, uv_Screen);

                float2 uv_RGB = frac(i.uv * tileSum) ;
                fixed4 col_RGB = tex2D(_RGBTex, uv_RGB);
                

                fixed2 uv_Dither = frac(i.uv * DitherSum);
                fixed4 col_Dither = tex2D(_DitherTex, uv_Dither);

                fixed4 col = col_Screen;

                float grey = dot(col_Screen.rgb, float3(0.299, 0.587, 0.114));
                switch(_DitherLevel)
                {
                    case 0:
                    //二阶灰度输出
                    if (0.5 < (1 - grey))
                    {
                        //墨点颜色
                        col = fixed4(0, 0, 0, 1);
                    }
                    else
                    {
                        //纸张颜色
                        col = fixed4(1, 1, 1, 1);
                    }

                    break;
                    case 1:
                    //红色通道22*2  4点黑白仿色
                    if (col_Dither.r < (1 - grey))
                    {
                        //墨点颜色
                        col = fixed4(0, 0, 0, 1);
                    }
                    else
                    {
                        //纸张颜色
                        col = fixed4(1, 1, 1, 1);
                    }
                    break;
                    case 2:
                    //绿色通道4*4  16点黑白仿色
                    if (col_Dither.g < (1 - grey))
                    {
                        //墨点颜色
                        col = fixed4(0, 0, 0, 1);
                    }
                    else
                    {
                        //纸张颜色
                        col = fixed4(1, 1, 1, 1);
                    }
                    break;
                    case 3:
                    //蓝色通道8*8  64点黑白仿色
                    if (col_Dither.b < (1 - grey))
                    {
                        //墨点颜色
                        col = fixed4(0, 0, 0, 1);
                    }
                    else
                    {
                        //纸张颜色
                        col = fixed4(1, 1, 1, 1);
                    }
                    break;
                }
                
                //判断使用RGB的哪个通道，与仿色结果进行相加，并且约束输出值为0~1
                switch(_DisplayModeID)
                {
                    case 1:
                    col = clamp(col + col_RGB.r, 0, 1);//红
                    break;
                    case 2:
                    col = clamp(col + col_RGB.g, 0, 1);//绿
                    break;
                    case 3:
                    col = clamp(col + col_RGB.b, 0, 1);//蓝
                    break;
                    case 4:
                    col = col * col_RGB.a;//透明
                    break;
                }

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
    }
}
