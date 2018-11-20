using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PulseEmitter : MonoBehaviour {
	public static float distance = 0.0f;
	public static float fadeDistance;
	public static float edgeSoftness;
	public List<Vector3> rays;

	public int speed = 25;
	public float space;

	void Start () {
		fadeDistance = 5f;
		edgeSoftness = 5f;
	}

	void Update () {
		distance += speed * Time.deltaTime;

		if (Input.GetMouseButtonDown(0)){
			EmitSound(100f, 8f);
		} else if (Input.GetMouseButtonDown(1)) {
			EmitSound(20f, 2f);
		}

		RayCasting();
	}

	void EmitSound(float freq, float intensity) {
		distance = 0.0f;
		var pulseOrigin = new Vector4(transform.position.x, transform.position.y, transform.position.z, 0);
		var visualizers = Object.FindObjectsOfType<PulseVisualizer>();

		foreach (var visualizer in visualizers) {
			visualizer.thisRenderer.material.SetVector("_Origin", pulseOrigin);
			visualizer.thisRenderer.material.SetFloat("_Frequency", freq);
			visualizer.thisRenderer.material.SetFloat("_Intensity", intensity);
		}
	}

	void RayCasting () {
		RaycastHit hit; 
		float raySum = 0;

		for (int i = 0; i < rays.Count; i++){
			if(Physics.Raycast(transform.position, rays[i], out hit)){
				var rayDistance = hit.distance;
				raySum += rayDistance;

				Debug.DrawRay(transform.position, rays[i] * rayDistance, Color.green);
			} else {
				Debug.DrawRay(transform.position, rays[i] * 10, Color.red);
			}
		}

		space = raySum / rays.Count;
	}
}
