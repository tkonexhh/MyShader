//制作：CRomputer_Luo(C罗老师)
//发布QQ群：129428063
Shader "CRLuo/SetRGBColor_S_R_RGB_Dob"
{  
       //-------------------------------【属性】-----------------------------------------  
       Properties  
       {  
       _BloodID ("血量百分比",Range (0, 10)) = 0

       _RColor ("红色",Color)=(1,0,0,1)

       _GColor ("绿色",Color)=(0,1,0,1)

       _BColor ("蓝色",Color)=(0,0,1,1)
 
       _RGBColorTex ("颜色贴图/RGB贴图",2D)="White"{}  
       
       _AmbientIntensity ("环境亮度",Range (0, 1)) = 0.5
       
       _ColorSetTex ("油漆范围",2D)="White"{}  
             
       _LightTex ("光照纹理贴图",2D)="White"{}
       

       _GroundIntensity ("除RGB颜色外底色亮度",Range (0, 1)) = 1

       _BumpMap("凹凸法线",2D)="bump"{}   

       _FlashColor ("闪烁颜色",Color)=(0,0,0,1)
       _FlashIntensity ("闪烁亮度", Range (0, 1)) = 0
       

       _EmissTex("自发光贴图",2D)="White"{}
       _EmissIntensity ("自发光强度", Range (0, 1)) = 0
              
       _Cube ("反射环境贴图", Cube) = "" {}
       _ReflePow("面比率强度", Range (0, 1)) = 0
      
       
       }  
   
		
       //---------------------------------【子着色器1】----------------------------------  
       SubShader  
       {  
 		//-----------子着色器标签----------  
            Tags { "RenderType" = "Opaque" }  
          LOD 400
          
Cull back
		
        //-------------------开始CG着色器编程语言段-----------------   
        CGPROGRAM  

	#pragma surface surf BlinnPhong
	
	#pragma target 3.0
	
	//input limit (8) exceeded, shader uses 9
	
	#pragma exclude_renderers d3d11_9x
             


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
        //自发光贴图
        sampler2D _EmissTex;

        //自发光强度
        float _EmissIntensity;

        //反射贴图
        samplerCUBE _Cube;
        //面比率强度
        float _ReflePow;


        //【2】输入结构    
        struct Input   
        {  
            //颜色纹理的uv值  
            float2 uv_RGBColorTex; 

            //光照纹理的uv值  
            float2 uv_LightTex;  
 
            //油漆范围纹理的uv值  
            float2 uv_ColorSetTex;
               
            //凹凸纹理的uv值
            float2 uv_BumpMap;

            //自发光纹理的uv值
            float2 uv_EmissTex;

            //包含了世界坐标系中的反射向量
            float3 worldRefl;  

            //法线修改后的表面
    		INTERNAL_DATA 

            //观察方向  
            float3 viewDir;
        };
  




        //【3】表面着色函数的编写  
        void surf (Input IN, inout SurfaceOutput o)   
        {  
             fixed4  C;
             fixed4  D;
             fixed4  R;
             fixed4  M;



            if(_BloodID == 10)
            {
            
            //获取光照
            D = tex2D (_LightTex, IN.uv_LightTex).r;  

            //获取涂装范围
            R = tex2D (_ColorSetTex, IN.uv_ColorSetTex).r;

            }
            
            else if(_BloodID > 7.5)
            {
            //先从主纹理获取rgb颜色值  
            D = tex2D (_LightTex, IN.uv_LightTex).g;  

            //获取涂装范围
            R = tex2D (_ColorSetTex, IN.uv_ColorSetTex).r;

            }

            else if(_BloodID > 5)
            {
            //先从主纹理获取rgb颜色值  
            D = tex2D (_LightTex, IN.uv_LightTex).g;  
            
                  
           
            
            //获取涂装范围
            R = tex2D (_ColorSetTex, IN.uv_ColorSetTex).g;
            }

            else 
            {
            //先从主纹理获取rgb颜色值  
            D = tex2D (_LightTex, IN.uv_LightTex).b;  

            //获取涂装范围
            R = tex2D (_ColorSetTex, IN.uv_ColorSetTex).b;

            }

            //获取底层金属范围
            M = ((1-R) * D) * 0.5;

            //油漆颜色
            C = ((1-R) + ( _RColor * tex2D (_RGBColorTex, IN.uv_RGBColorTex).r + _GColor* tex2D (_RGBColorTex, IN.uv_RGBColorTex).g + _BColor * tex2D (_RGBColorTex, IN.uv_RGBColorTex).b)*R);  

            //压暗非涂装部分
            C = C *  R + C*((1 -  R) * _GroundIntensity);

            //使用油漆光泽重新定义反射
            R = R * ( _RColor.a * tex2D (_RGBColorTex, IN.uv_RGBColorTex).r  + _GColor.a * tex2D (_RGBColorTex, IN.uv_RGBColorTex).g + _BColor.a * tex2D (_RGBColorTex, IN.uv_RGBColorTex).b);





            //从凹凸纹理获取法线值  
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));  

            //获取法线后的反射表面
	    	float3 worldRefl = WorldReflectionVector (IN, o.Normal);

	    	//反射环境图案
	   		fixed4 reflcol = texCUBE (_Cube, worldRefl);
            
            
            
            //边缘强度
            half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));    
            

            //组织好的表面颜色
            o.Albedo = C;


			//光泽混合 = 表面颜色 * 表做旧 * 反向涂装范围（压低无高光范围的部分） + 表面颜色 * 油漆范围 * 反射图像 
            o.Albedo = (o.Albedo  * D *(1-R) 
            			+ 
            			o.Albedo * R * reflcol)*(1-M) + M * reflcol;
            			

			//闪烁混合
            o.Albedo = o.Albedo * (1-_FlashIntensity) 
            			 +  
            			 _FlashIntensity * _FlashColor;



             o.Emission = (
            				o.Albedo*_AmbientIntensity*(1-R) 
            				+ tex2D (_EmissTex, IN.uv_EmissTex) *_EmissIntensity
            				+ reflcol * C * pow (rim, _ReflePow)*R
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

	#pragma surface surf BlinnPhong
	
	#pragma target 3.0
	
	//input limit (8) exceeded, shader uses 9
	
	#pragma exclude_renderers d3d11_9x
             


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
        //自发光贴图
        sampler2D _EmissTex;

        //自发光强度
        float _EmissIntensity;

        //反射贴图
        samplerCUBE _Cube;
        //面比率强度
        float _ReflePow;


        //【2】输入结构    
        struct Input   
        {  
            //颜色纹理的uv值  
            float2 uv_RGBColorTex; 

            //光照纹理的uv值  
            float2 uv_LightTex;  
 
            //油漆范围纹理的uv值  
            float2 uv_ColorSetTex;
               
            //凹凸纹理的uv值
            float2 uv_BumpMap;

            //自发光纹理的uv值
            float2 uv_EmissTex;

            //包含了世界坐标系中的反射向量
            float3 worldRefl;  

            //法线修改后的表面
    		INTERNAL_DATA 

            //观察方向  
            float3 viewDir;
        };
  




        //【3】表面着色函数的编写  
        void surf (Input IN, inout SurfaceOutput o)   
        {  
             fixed4  C;
             fixed4  D;
             fixed4  R;




            if(_BloodID == 10)
            {
            
            //获取光照
            D = tex2D (_LightTex, IN.uv_LightTex).r;  
            
                  
           
                        //获取涂装范围
            R = tex2D (_ColorSetTex, IN.uv_ColorSetTex).r;

            }
            
            else if(_BloodID > 7.5)
            {
            //先从主纹理获取rgb颜色值  
            D = tex2D (_LightTex, IN.uv_LightTex).g;  
            
                  
           
            
            //获取涂装范围
            R = tex2D (_ColorSetTex, IN.uv_ColorSetTex).r;

            }

           else if(_BloodID > 5)
            {
            //先从主纹理获取rgb颜色值  
            D = tex2D (_LightTex, IN.uv_LightTex).g;  
            
                  
           
            
            //获取涂装范围
            R = tex2D (_ColorSetTex, IN.uv_ColorSetTex).g;
            }

            else 
            {
            //先从主纹理获取rgb颜色值  
            D = tex2D (_LightTex, IN.uv_LightTex).b;  
            
                  
            
            
            //获取涂装范围
            R = tex2D (_ColorSetTex, IN.uv_ColorSetTex).b;

            }

            //油漆颜色
            C = ((1-R) + ( _RColor * tex2D (_RGBColorTex, IN.uv_RGBColorTex).r + _GColor* tex2D (_RGBColorTex, IN.uv_RGBColorTex).g + _BColor * tex2D (_RGBColorTex, IN.uv_RGBColorTex).b)*R);  

            //压暗非涂装部分
            C = C *  R + C*((1 -  R) * _GroundIntensity);

            //使用油漆光泽重新定义反射
            R = R * ( _RColor.a * tex2D (_RGBColorTex, IN.uv_RGBColorTex).r  + _GColor.a * tex2D (_RGBColorTex, IN.uv_RGBColorTex).g + _BColor.a * tex2D (_RGBColorTex, IN.uv_RGBColorTex).b);





            //从凹凸纹理获取法线值  
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));  

            //获取法线后的反射表面
	    	float3 worldRefl = WorldReflectionVector (IN, o.Normal);

	    	//反射环境图案
	   		fixed4 reflcol = texCUBE (_Cube, worldRefl);
            
            
            
            //边缘强度
            half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));    
            


            o.Albedo = C;


			//光泽混合
            o.Albedo = o.Albedo * D *(1-R) 
            			+ 
            			o.Albedo * R * reflcol;
            			

			//闪烁混合
            o.Albedo = o.Albedo * (1-_FlashIntensity) 
            			 +  
            			 _FlashIntensity * _FlashColor;



             o.Emission = (tex2D (_EmissTex, IN.uv_EmissTex) *_EmissIntensity
            				+ reflcol * C * pow (rim, _ReflePow)*R*_AmbientIntensity
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