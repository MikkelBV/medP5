using UnityEngine;
using System.Collections;

public class PulseDistance : MonoBehaviour {
	
	public Material pulseMaterial;
	public static float distance = 0.0f;
	public static float fadeDistance;
	public static float edgeSoftness;
	public static Vector4 pulseOrigin;
	public Transform player;
	public static Transform target = null;
	public int distMult = 0;
	private bool fadeOut;

	// Use this for initialization
	void Start () 
	{
		player = GameObject.FindGameObjectWithTag("Player").transform;
		pulseOrigin = new Vector4(0,0,0,1);
		fadeDistance = 5f;
		edgeSoftness = 5f;
		target = player;
		fadeOut = false;
	}
	
	// Update is called once per frame
	void Update ()
	{
		Debug.Log(player.position);
		pulseOrigin = new Vector4(player.position.x, player.position.y, player.position.z, 0);
		distance += distMult*Time.deltaTime;

		if (Input.GetMouseButtonDown(1)){
			//fadeDistance = 5.0f;
			//edgeSoftness = 5.0f;
			distance = 0.0f;
		}
		
		//if (distance > 2){
		//	fadeOut = true;
		//}

		if (fadeOut){
			fadeDistance -= 0.03f;
			edgeSoftness -= 0.03f;
				if (fadeDistance <= 1.0 || edgeSoftness <= 1.0){
					fadeDistance = 0.0f;
					edgeSoftness = 0.0f;
					fadeOut = false;
				}
		}
	
		/*
		RaycastHit hit;
		if(Physics.Raycast(player.transform.position, player.transform.forward, out hit))
		{
			//print(hit.transform.name);
			//if(Input.GetMouseButtonDown(0))
			//{
				//target = hit.transform;
				//hit.transform.GetComponent<ColorObjects>().isTarget = true;
			//}
		}
		*/
		
		//grub check and killdistance omitted
	}

	public void setDistance(float _distance){
		distance = _distance;
	}

	public float getDistance(){
		return distance;
	}

	public void setOrigin(Vector4 _origin){
		pulseOrigin = _origin;
	}

	public Vector4 getOrigin(){
		return pulseOrigin;
	}

	
}
