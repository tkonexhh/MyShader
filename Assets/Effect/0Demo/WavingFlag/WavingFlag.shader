Shader "Unlit/WavingFlag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Frame ("Frame", float) = 1.0
        _Speed ("Speed", float) = 1.0
        _Count ("Count", float) = 2.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Cull Off
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float4 normal: NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 normal: NORMAL;
                float4 vertex: SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Frame;
            float _Speed;
            float _Count;

            v2f vert(appdata v)
            {
                v2f o;
                //v.vertex += (sin((v.normal - _Time.w * _Speed) * _Count)) * v.normal * _Frame;
                v.vertex.z += (sin((v.uv.x - _Time.w * _Speed) * _Count)) * v.uv.x * _Frame;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
            
        }
    }
}
