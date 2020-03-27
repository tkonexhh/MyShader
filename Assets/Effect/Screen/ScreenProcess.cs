using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenProcess : MonoBehaviour
{
    public Material material;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material!=null)
        //渲染输入，渲染输出，特效材质球
        Graphics.Blit(src, dest, material);
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
