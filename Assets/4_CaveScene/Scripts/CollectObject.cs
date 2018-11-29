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

	void OnCollisionEnter(Collision other)
	{
		if (other.gameObject.tag == "Sphere"){
			spheres+=1;
			other.gameObject.SetActive(false);
			Debug.Log(spheres +":"+ cubes);
			particles.Emit(5);
		}		
		if (other.gameObject.tag == "Cube"){
			cubes+=1;
			other.gameObject.SetActive(false);
			Debug.Log(spheres +":"+ cubes);
			particles.Emit(5);
		}
	}
}
