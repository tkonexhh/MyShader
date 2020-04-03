Shader "Unlit/BurnPaper"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _AshTex ("Alsh Tex", 2D) = "White" { }
        _FlowVector ("Flow Vector", vector) = (0, 0, 0, 0)
        _NoiseTex1 ("Noise Tex1", 2D) = "White" { }
        _NoiseTex2 ("Noise Tex2", 2D) = "White" { }
        [HDR] _SparkColor ("Spark Color", Color) = (1, 1, 1, 1)

        _Blend ("Blend", Range(0, 1)) = 1
        _Range ("Range", Range(0, 1)) = 1

        [HDR]_BurnColor ("Range Color", Color) = (1, 1, 1, 1)
        _BurnRange ("FireRange", Range(0, 1)) = 0

        _EmberRange ("Ember Range", Range(0, 1)) = 0.1
        _VertOffset ("Vert Offset", Range(0, 1)) = 0.5
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
                float4 uv_Noise: TEXCOORD1;
                //UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _AshTex;
            sampler2D _NoiseTex1;
            float4 _NoiseTex1_ST;
            sampler2D _NoiseTex2;
            float4 _NoiseTex2_ST;
            
            float4 _FlowVector;
            

            float4 _SparkColor;

            float _Blend;
            float _Range;
            float4 _BurnColor;
            float _BurnRange;

            float _EmberRange;

            float _VertOffset;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_Noise = TRANSFORM_TEX(v.uv, _NoiseTex1).xyxy * half4(1, 1, 1.3, 1.3) + _FlowVector * _Time.x;

                float4 noiseuv = float4(v.uv * _NoiseTex2_ST.xy + _NoiseTex2_ST.zw * _Time.x, 0, 0) ;
                fixed noise = tex2Dlod(_NoiseTex2, noiseuv);
                _Blend = _Blend * 4 - 1;
                half vertOffset = noise * _VertOffset * saturate(1 - (o.uv.x * 4 - _Blend));

                o.vertex = UnityObjectToClipPos(v.vertex + half4(0, 0, vertOffset, 0));
                //UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }




            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col_Ash = tex2D(_AshTex, i.uv);
                fixed4 col_Noise = tex2D(_NoiseTex1, i.uv_Noise.xy);
                fixed4 col_Noise2 = tex2D(_NoiseTex2, i.uv_Noise.zw);
                // apply fog
                
                float4 noise = abs(col_Noise + col_Noise2 - 1);

                //火星效果
                fixed3 spark = (smoothstep(0.8, 1, noise)) * _SparkColor;

                //颜色差值
                half blendValue = smoothstep(_Blend - _Range, _Blend + _Range, i.uv.x + noise.x * _Range);

                //火焰色
                float3 burnRange = blendValue * (1 - blendValue) * _BurnColor;

                clip(col.a * (i.uv.x + noise * _Range) - (_Blend - _Range - _EmberRange));
                col.rgb = lerp(col_Ash + spark, col, blendValue) + burnRange;
                float4 final = col;
                //UNITY_APPLY_FOG(i.fogCoord, final);
                return  final;
            }
            ENDCG
            
        }
    }
}
