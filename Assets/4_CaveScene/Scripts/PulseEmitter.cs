using UnityEngine;
using System.Collections;

public class PulseEmitter : MonoBehaviour {
	public static float distance = 0.0f;
	public static float fadeDistance;
	public static float edgeSoftness;
	public static Vector4 pulseOrigin;

	public bool fadeOut = false;
	public int distMult = 0;

	void Start () {
		pulseOrigin = new Vector4(0,0,0,1);
		fadeDistance = 5f;
		edgeSoftness = 5f;
	}

	void Update () {
		pulseOrigin = new Vector4(transform.position.x, transform.position.y, transform.position.z, 0);
		distance += distMult*Time.deltaTime;

		if (Input.GetMouseButtonDown(1)){
			distance = 0.0f;
		}

		if (fadeOut){
			fadeDistance -= 0.03f;
			edgeSoftness -= 0.03f;

			if (fadeDistance <= 1.0 || edgeSoftness <= 1.0){
				fadeDistance = 0.0f;
				edgeSoftness = 0.0f;
				fadeOut = false;
			}
		}
	}
}
