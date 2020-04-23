using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Wobble : MonoBehaviour
{

    Renderer render;
    Vector3 lastPos;
    Vector3 velocity;
    Vector3 lastRot;
    Vector3 rotVelocity;
    float time=0.5f;


    // Start is called before the first frame update
    void Start()
    {
        render=GetComponent<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
            time+=Time.deltaTime;



            //记录当前坐标和旋转角度
            lastPos=transform.position;
            lastRot=transform.rotation.eulerAngles;
    }
}
