// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Liquidbottle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _MainColor ("MainColor", Color) = (1, 1, 1, 1)
        _TopColor ("TopColor", Color) = (1, 1, 0, 1)
        _TopEdgeWidth ("TopEdgeWidth", Range(0, 0.1)) = 0.1
        _FillAmount ("FillAmount", Range(-1, 2)) = 0

        _RimColor ("RimColor", Color) = (1, 1, 1, 1)
        _RimWidth ("RimWidth", Range(0, 0.2)) = 0.1

        _BottleColor ("BottleColor", Color) = (1, 1, 1, 0.1)
        _BottleWidth ("BottleWidth", Range(0.01, 0.2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Pass
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
            //ZWrite Off
            Cull Off
            //AlphaToMask On
            //Blend SrcAlpha OneMinusSrcAlpha
            
            
            CGPROGRAM
            
            // Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members worldPos)
            //#pragma exclude_renderers d3d11
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
                float3 normal: NORMAL;
                float3 viewDir: COLOR;
                float fillEdge: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _MainColor;
            float4 _TopColor;
            float _TopEdgeWidth;
            float _FillAmount;

            float4 _RimColor;
            float _RimWidth;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex.xyz);//.xyz;
                //这一句和上一句又什么不同？？？？
                // float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = v.normal;
                o.fillEdge = worldPos.y + _FillAmount;
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag(v2f i, fixed facing: VFACE): SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                float rim = 1 - pow(dot(i.normal, i.viewDir), _RimWidth);
                float rimColor = rim * _RimColor;


                float4 topEdge = step(i.fillEdge, 0.5) - step(i.fillEdge, 0.5 - _TopEdgeWidth);
                float4 topEdgeColor = _TopColor * 0.9 * topEdge;
                
                float4 result = step(i.fillEdge, 0.5) - topEdge;
                float4 resultColor = result * col;

                resultColor += topEdgeColor + rimColor;

                float4 topColor = _TopColor * (result + topEdge);
                
                return facing > 0?resultColor: topColor;
            }
            ENDCG
            
        }


        Pass//2
        {
            Cull Front
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
                float4 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
            };

            float _BottleWidth;
            float4 _BottleColor;
            v2f vert(appdata v)
            {
                v2f o;
                v.vertex += v.normal * _BottleWidth;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = _BottleColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
    }
}
