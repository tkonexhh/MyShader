Shader "Unlit/VertexNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _NoiseTex ("Noise Tex", 2D) = "white" { }
        _Speed ("Speed", Range(10, 200)) = 30
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
                float2 uv_noise: TEXCOORD1;
                //UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            float _Speed;

            v2f vert(appdata v)
            {
                v2f o;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_noise = TRANSFORM_TEX(v.uv, _NoiseTex);
                float offsetz = sin(_Time.x * _Speed) * o.uv.y * o.uv.y ;
                
                float4 noiseuv = float4(v.uv, 0, 0);
                float4 col = tex2Dlod(_NoiseTex, noiseuv);
                o.vertex = UnityObjectToClipPos(v.vertex + col / 10) ;
                //UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 col_noise = tex2D(_NoiseTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col + col_noise * 0.2;
            }
            ENDCG
            
        }
    }
}
