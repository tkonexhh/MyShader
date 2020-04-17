#ifndef MY_CG_INCLUDED
    #define MY_CG_INCLUDED

    #define _ColorGrey fixed3(0.299, 0.587, 0.114)

    fixed4 ColorToGrey(fixed4 color)
    {
        float grey = dot(color.rgb, _ColorGrey);
        return fixed4(grey, grey, grey, color.a);
    }

#endif // MY_CG_INCLUDED