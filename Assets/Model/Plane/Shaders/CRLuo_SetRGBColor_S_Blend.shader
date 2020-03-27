//制作：CRomputer_Luo(C罗老师)
//发布QQ群：129428063
Shader "CRLuo/SetRGBColor_S_Blend"
{  
       //-------------------------------【属性】-----------------------------------------  
       Properties  
       {  
       _BloodID ("血量",Range (0, 10)) = 0
       _RColor ("红色通道颜色",Color)=(1,0,0,1)
       _GColor ("绿色通道颜色",Color)=(0,1,0,1)
       _BColor ("蓝色通道颜色",Color)=(0,0,1,1)
               //纹理  
       _RGBColorTex ("涂装贴图",2D)="White"{}  
       
       _AmbientIntensity ("环境亮度",Range (0, 1)) = 0.5
       
       _ColorSetTex ("着色范围通道贴图",2D)="White"{}  
             
       _LightTex ("光泽通道贴图",2D)="White"{}
       

       _GroundIntensity ("无涂装底色亮度",Range (0, 1)) = 1

       _BumpMap("法线贴图",2D)="bump"{}   

       _FlashColor ("闪烁颜色",Color)=(0,0,0,1)
       _FlashIntensity ("闪烁亮度", Range (0, 1)) = 0
       

       _EmissTex("自发光贴图",2D)="White"{}
       _EmissIntensity ("自发光亮度", Range (0, 1)) = 0
              
       
       _RefleColor ("勾边颜色",Color)=(0,0,0,1)
       _ReflePow("勾边范围", Range (0, 1)) = 0
       _RefleIntensity ("沟边强度", Range (0, 1)) = 0
       
       }  
   
		
       //---------------------------------【子着色器1】----------------------------------  
       SubShader  
       {  
       
        		//-----------子着色器标签----------  
            Tags { "Queue"="Transparent" "RenderType" = "Transparent" }  
          LOD 200
          //Blend SrcAlpha OneMinusSrcAlpha
          //Blend one one
           Blend SrcColor one
           //Blend SrcColor OneMinusSrcAlpha

          
          
Cull back
        //-------------------开始CG着色器编程语言段-----------------   
        CGPROGRAM  
  
        //【1】光照模式声明：使用兰伯特光照模式  
        #pragma surface surf BlinnPhong  
        //#pragma surface surf BlinnPhong  
        #pragma target 3.0 
             


        //变量声明  
        
        int _BloodID;
        //三色定义
        fixed4  _RColor; 
        fixed4  _GColor; 
        fixed4  _BColor; 
        
        //RGB颜色通道
        sampler2D _RGBColorTex; 
        
        //涂装范围
        sampler2D _ColorSetTex;
        //做旧颜色
        sampler2D _LightTex;  
        
        //RGB无法控制的底色亮度
        float _GroundIntensity;
        
        //环境亮度
        float _AmbientIntensity;

		//凹凸贴图
        sampler2D _BumpMap;
        
		//闪烁颜色
        fixed4  _FlashColor;
        //闪烁强度
        float _FlashIntensity;
         
        //自发光强度
        float _EmissIntensity;
        //自发光贴图
        sampler2D _EmissTex;
        
        //反射强度
        float _RefleIntensity;
        float _ReflePow;
        //反射贴图
        fixed4 _RefleColor;


        //【2】输入结构    
            struct Input   
            {  
            //主纹理的uv值  
            float2 uv_LightTex;  
            //细节纹理的uv值  
            float2 uv_RGBColorTex;  

            float2 uv_ColorSetTex;
               
            //凹凸纹理的uv值
            float2 uv_BumpMap;
            //自发光纹理的uv值
            float2 uv_EmissTex;
            
            float2 uv_Reflections;
            
            float3 viewDir;//观察方向  
            };
  




        //【3】表面着色函数的编写  
        void surf (Input IN, inout SurfaceOutput o)   
        {  
             fixed4  C;

             fixed4 RGBTxt;
             RGBTxt = tex2D (_RGBColorTex, IN.uv_RGBColorTex);
              RGBTxt =  _RColor * RGBTxt.r + _GColor *RGBTxt.g + _BColor * RGBTxt.b;
             fixed4 LigTxt;
             LigTxt = tex2D (_LightTex, IN.uv_LightTex);

             fixed4 SetTxt;
             SetTxt = tex2D (_ColorSetTex, IN.uv_ColorSetTex);


            if(_BloodID == 10)
            {
                  
            //设置细节纹理  
            C = lerp(LigTxt.r * _GroundIntensity,
                     LigTxt.r * RGBTxt,
                      SetTxt.r);

            }
            
            else if(_BloodID > 7.5)
            {
                  
            //设置细节纹理  
            C = lerp(LigTxt.g * _GroundIntensity,
                     LigTxt.g * RGBTxt,
                      SetTxt.r);

            }

            else if(_BloodID > 5)
            {
                  
            //设置细节纹理  
            C = lerp(LigTxt.g * _GroundIntensity,
                     LigTxt.g * RGBTxt,
                      SetTxt.g);

            }

            else
            {
                  
            //设置细节纹理  
            C = lerp(LigTxt.b * _GroundIntensity,
                     LigTxt.b * RGBTxt,
                      SetTxt.b);

            }

			o.Albedo = C;

			//闪烁混合
            o.Albedo = o.Albedo*
            			 (1-_FlashIntensity) 
            			 +  
            			 _FlashIntensity * _FlashColor;
            			 
            //从凹凸纹理获取法线值  
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));  
            
            
            //该像素的镜面高光
           // o.Specular; 
            
            //该像素的发光强度
           // o.Gloss; 
            
            
            
            //边缘颜色    
            half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));    
            
            
            
            o.Emission = (
            				o.Albedo*_AmbientIntensity*(1-_RefleIntensity) 
            				+ tex2D (_EmissTex, IN.uv_EmissTex) *_EmissIntensity
            				+ _RefleColor.rgb * pow (rim, _ReflePow)*_RefleIntensity
            			)
            			*
            			 (1-_FlashIntensity) 
            			 +  
            			 _FlashIntensity * _FlashColor;
            			 
         }  
  
          //-------------------结束CG着色器编程语言段------------------  
        ENDCG
  
  
  
  Cull front
         //-------------------开始CG着色器编程语言段-----------------   
        CGPROGRAM  
  
        //【1】光照模式声明：使用兰伯特光照模式  
            #pragma surface surf Lambert 
             #pragma target 3.0 
             
            


        //变量声明  
        
        int _BloodID;
        //三色定义
        fixed4  _RColor; 
        fixed4  _GColor; 
        fixed4  _BColor; 
        
        //RGB颜色通道
        sampler2D _RGBColorTex; 
        
        //涂装范围
        sampler2D _ColorSetTex;
        //做旧颜色
        sampler2D _LightTex;  
        
        //RGB无法控制的底色亮度
        float _GroundIntensity;
        
        //环境亮度
        float _AmbientIntensity;

		//凹凸贴图
        sampler2D _BumpMap;
        
		//闪烁颜色
        fixed4  _FlashColor;
        //闪烁强度
        float _FlashIntensity;
         
        //自发光强度
        float _EmissIntensity;
        //自发光贴图
        sampler2D _EmissTex;
        
        //反射强度
        float _RefleIntensity;
        float _ReflePow;
        //反射贴图
        fixed4 _RefleColor;


        //【2】输入结构    
            struct Input   
            {  
            //主纹理的uv值  
            float2 uv_LightTex;  
            //细节纹理的uv值  
            float2 uv_RGBColorTex;  

            float2 uv_ColorSetTex;
               
            //凹凸纹理的uv值
            float2 uv_BumpMap;
            //自发光纹理的uv值
            float2 uv_EmissTex;
            
            float2 uv_Reflections;
            
            float3 viewDir;//观察方向  
            };
  




        //【3】表面着色函数的编写  
        void surf (Input IN, inout SurfaceOutput o)   
        {  

             fixed4  C;

             fixed4 RGBTxt;
             RGBTxt = tex2D (_RGBColorTex, IN.uv_RGBColorTex);
             RGBTxt =  _RColor * RGBTxt.r + _GColor *RGBTxt.g + _BColor * RGBTxt.b;
             fixed4 LigTxt;
             LigTxt = tex2D (_LightTex, IN.uv_LightTex);

             fixed4 SetTxt;
             SetTxt = tex2D (_ColorSetTex, IN.uv_ColorSetTex);




            if(_BloodID == 10)
            {
                  
            //设置细节纹理  
            C = lerp(LigTxt.r * _GroundIntensity,
                     LigTxt.r * RGBTxt,
                      SetTxt.r);

            }
            
            else if(_BloodID > 7.5)
            {
                  
            //设置细节纹理  
            C = lerp(LigTxt.g * _GroundIntensity,
                     LigTxt.g * RGBTxt,
                      SetTxt.r);

            }

            else if(_BloodID > 5)
            {
                  
            //设置细节纹理  
            C = lerp(LigTxt.g * _GroundIntensity,
                     LigTxt.g * RGBTxt,
                      SetTxt.g);

            }

            else
            {
                  
            //设置细节纹理  
            C = lerp(LigTxt.b * _GroundIntensity,
                     LigTxt.b * RGBTxt,
                      SetTxt.b);

            }


			o.Albedo = C * 0.5;

			//闪烁混合
            o.Albedo = o.Albedo*
            			 (1-_FlashIntensity) 
            			 +  
            			 _FlashIntensity * _FlashColor;
            			 
            //从凹凸纹理获取法线值  
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));  
            
            
            //该像素的镜面高光
           // o.Specular; 
            
            //该像素的发光强度
           // o.Gloss; 
            
            
            
            //边缘颜色    
            half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));    
            
            
            
            o.Emission = (
            				o.Albedo*_AmbientIntensity*(1-_RefleIntensity) 
            				+ tex2D (_EmissTex, IN.uv_EmissTex) *_EmissIntensity
            				+ _RefleColor.rgb * pow (rim, _ReflePow)*_RefleIntensity
            			)
            			*
            			 (1-_FlashIntensity) 
            			 +  
            			 _FlashIntensity * _FlashColor;
            			 
         }  
  
          //-------------------结束CG着色器编程语言段------------------  
        ENDCG
 
}
  
    //“备胎”为普通漫反射  
    Fallback "Specular"  
  
} 