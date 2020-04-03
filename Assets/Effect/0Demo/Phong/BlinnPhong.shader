Shader "Demo/Light/BlinnPhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Gloss ("Diffuse", Range(0, 10)) = 1
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
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float3 uv: NORMAL;
            };

            struct v2f
            {
                float3 uv: TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Diffuse;
            fixed _Gloss;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = UnityObjectToWorldNormal(v.uv);
                
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.uv);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.uv));
                
                fixed3 halfDir = normalize(i.uv + worldLight);
                //fixed3 diffuse = _LightColor0.rgb * _Diffuse.xyz * halfLambert;
                //fixed4 specular = _LightColor0.rgb * _Diffuse.xyz * pow(max(0, dot(i.uv, halfDir)), _Gloss)
                
                // sample the texture
                fixed4 col = fixed4(halfDir, 1);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
    }
}
