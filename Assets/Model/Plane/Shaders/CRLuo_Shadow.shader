//制作：CRomputer_Luo(C罗老师)
//发布QQ群：129428063
Shader "CRLuo/Shadow"
{  
       //-------------------------------【属性】-----------------------------------------  
       Properties  
       {  
  
       _ShadowTex ("DamageTex",2D)="White"{}

       
       }  
   
       //---------------------------------【子着色器1】----------------------------------  
       SubShader  
       {  
 		//-----------子着色器标签----------  
            Tags { "RenderType" = "Opaque" }  
 // LOD 200
        //-------------------开始CG着色器编程语言段-----------------   
        CGPROGRAM  
  
        //【1】光照模式声明：使用兰伯特光照模式  
            #pragma surface surf Lambert  
             #pragma target 3.0 



        //做旧颜色
        sampler2D _ShadowTex;  



        //【2】输入结构    
            struct Input   
            {  
            //主纹理的uv值  
            float2 uv_ShadowTex; 

            };
  




        //【3】表面着色函数的编写  
        void surf (Input IN, inout SurfaceOutput o)   
        {  
            //先从主纹理获取rgb颜色值  
            o.Albedo = tex2D (_ShadowTex, IN.uv_ShadowTex).rgb;  
            
             
            			 
         }  
  
        //-------------------结束CG着色器编程语言段------------------  
        ENDCG  
    }  
  
    //“备胎”为普通漫反射  
    Fallback "Diffuse"  
  
} 