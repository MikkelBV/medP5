using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollectObject : MonoBehaviour {
	private int spheres;
	private int cubes;
	ParticleSystem particles;

	void Start () {
		spheres = 0;
		cubes = 0;
		particles = GetComponent<ParticleSystem>();
	}
	
	void Update () {
	}

	//"Player" gameobjekt collision
	void OnCollisionEnter(Collision other)
	{
		if (other.gameObject.tag == "Sphere"){
			spheres+=1;
			Debug.Log(spheres +":"+ cubes);
			other.gameObject.SetActive(false);
			particles.Emit(5);
		}		
		if (other.gameObject.tag == "Cube"){
			cubes+=1;
			Debug.Log(spheres +":"+ cubes);
			other.gameObject.SetActive(false);
			particles.Emit(5);
		}
	}

	//"OVRPlayerController gameobject collision
	void OnControllerColliderHit(ControllerColliderHit otherC){
		if (otherC.gameObject.tag == "Sphere"){
			spheres+=1;
			Debug.Log(spheres +":"+ cubes);
			otherC.gameObject.SetActive(false);
			particles.Emit(5);
		}		
		if (otherC.gameObject.tag == "Cube"){
			cubes+=1;
			Debug.Log(spheres +":"+ cubes);
			otherC.gameObject.SetActive(false);
			particles.Emit(5);
		}
	}


}
