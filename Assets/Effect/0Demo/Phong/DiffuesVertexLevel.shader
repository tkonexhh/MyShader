// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/DiffuesVertexLevel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                //float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                fixed3 Color: COLOR;
                //float2 uv: TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Diffuse;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.xyz * saturate(dot(worldNormal, worldLight));
                o.Color = ambient + diffuse;
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(i.Color, 1);
            }
            ENDCG
            
        }
    }
    Fallback "DIFFUSE"
}
