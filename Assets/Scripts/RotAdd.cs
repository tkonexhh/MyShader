//制作：CRomputer_Luo(C罗老师)
//发布QQ群：129428063
using UnityEngine;
using System.Collections;

public class RotAdd : MonoBehaviour {
	public Vector3 RotSpeed;
	// Use this for initialization
	void Start () {
	}

	void Update () {
		this.gameObject.transform.localRotation = Quaternion.Euler( RotSpeed*Time.time);
	}
}
