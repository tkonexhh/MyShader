Shader "Unlit/Wireframe"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _FillColor ("FillColor", Color) = (1, 1, 1, 1)
        _WireColor ("WireColor", Color) = (1, 0, 0, 1)
        _WireWidth ("WireWidth", Range(0, 0.005)) = 1
        _Clip ("Clip", Range(0, 2.5)) = 1
        _Lerp ("Lerp", Range(0, 1)) = 0.5
        _WireLerpWidth ("WireLerpWidth", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" }
        LOD 100

        Pass
        {
            CGPROGRAM
            
            // Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
            #pragma exclude_renderers gles
            
            #pragma target 4.0
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2g
            {
                float3 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
                float4 worldPos: POSITION1;
            };

            struct g2f
            {
                float4 pos: SV_POSITION;
                float4 worldPos: POSITION1;
                float3 uv: TEXCOORD0;
                float3 dist: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _FillColor;
            float4 _WireColor;
            float _WireWidth;
            float _WireLerpWidth;

            float _Lerp;
            float _Clip;

            v2g vert(appdata v)
            {
                v2g o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.z = _Clip - v.vertex.y - 1;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream < g2f > triStream)
            {
                if (_WireWidth == 0)return;
                float2 p0 = IN[0].vertex.xy / IN[0].vertex.w;
                float2 p1 = IN[1].vertex.xy / IN[1].vertex.w;
                float2 p2 = IN[2].vertex.xy / IN[2].vertex.w;

                float2 v0 = p2 - p1;
                float2 v1 = p2 - p0;
                float2 v2 = p1 - p0;
                //triangles area
                float area = abs(v1.x * v2.y - v1.y * v2.x);

                //到三条边的最短距离
                g2f OUT;
                OUT.worldPos = IN[0].worldPos;
                OUT.pos = IN[0].vertex;
                OUT.uv = IN[0].uv;
                OUT.dist = float3(area / length(v0), 0, 0);
                triStream.Append(OUT);

                OUT.worldPos = IN[1].worldPos;
                OUT.pos = IN[1].vertex;
                OUT.uv = IN[1].uv;
                OUT.dist = float3(0, area / length(v1), 0);
                triStream.Append(OUT);

                OUT.worldPos = IN[2].worldPos;
                OUT.pos = IN[2].vertex;
                OUT.uv = IN[2].uv;
                OUT.dist = float3(0, 0, area / length(v2));
                triStream.Append(OUT);
            }
            

            fixed4 frag(g2f i): SV_Target
            {
                clip(i.uv.z);
                if (i.uv.z > _Clip)
                {
                    i.pos.y = _Clip - 0.6;
                }
                fixed4 col_Wire;
                float d = min(i.dist.x, min(i.dist.y, i.dist.z));
                col_Wire = d < _WireWidth?_WireColor: _FillColor;

                
                //颜色差值
                half blendValue = smoothstep(_Lerp - _WireLerpWidth, _Lerp + _WireLerpWidth, i.uv.z);
                

                fixed4 col_Tex = tex2D(_MainTex, i.uv);
                return lerp(col_Wire, col_Tex, blendValue);
            }
            ENDCG
            
        }
    }
}
