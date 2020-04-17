Shader "Unlit/QueueTransparent"
{
    Properties
    {
        _OutlineColor ("OutlineColor", Color) = (1, 0, 0, 1)
        _OutlineLength ("OutlineLength", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass//第一个PASS渲染人物正面
        {

            Tags { "LightMode" = "Always" }
            Cull Back
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            
            float4 _OutlineColor;
            float _OutlineLength;

            float4 vert(appdata_base v): SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            fixed4 frag(): SV_Target
            {
                
                return half4(1, 1, 1, 1);
            }
            ENDCG
            
        }

        Pass
        {

            Tags { "LightMode" = "ForwardBase" }

            Cull Front
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };


            struct v2f
            {
                float4 pos: SV_POSITION;
            };


            fixed4 _OutlineColor;
            fixed _OutlineLength;

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal.xyz);
                float2 extendDir = normalize(TransformViewToProjection(viewNormal.xy));

                float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ScreenParams.y));//将近裁剪面右上角位置的顶点变换到观察空间
                float aspect = abs(nearUpperRight.y / nearUpperRight.x);//得到屏幕长宽比

                o.pos.xy += extendDir * aspect * (_OutlineLength * 0.05);

                

                return o;
            }

            fixed4 frag(v2f i): SV_TARGET
            {
                return _OutlineColor;
            }

            
            ENDCG
            
        }
    }
}
