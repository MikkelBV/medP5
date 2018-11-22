using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PulseEmitter : MonoBehaviour {
	public static float distance = 0.0f;
	public List<Vector3> rays;
	public AudioClip AudioClip;
	AudioSource audioSource;
	public int speed = 25;
	public float space;

	private PulseVisualizer[] visualisers;

	void Start () {
		audioSource = GetComponent<AudioSource>();
		visualisers = Object.FindObjectsOfType<PulseVisualizer>();
		Debug.Log(visualisers.Length);
	}

	void Update () {
		distance += speed * Time.deltaTime;

		if (Input.GetMouseButtonDown(0)){
			EmitSound(100f, 8f);
			audioSource.PlayOneShot(AudioClip, 1F);
			audioSource.PlayDelayed(44100);
		} else if (Input.GetMouseButtonDown(1)) {
			EmitSound(20f, 2f);
		}
 
		RayCasting();
	}

	void EmitSound(float freq, float intensity) {
		var pulseOrigin = new Vector4(transform.position.x, transform.position.y, transform.position.z, 0);

		foreach (var visualizer in visualisers) {
			visualizer.thisRenderer.material.SetVector("_Origin", pulseOrigin);
			visualizer.thisRenderer.material.SetFloat("_Frequency", freq);
			visualizer.thisRenderer.material.SetFloat("_Intensity", intensity);
		}

		distance = 0.0f;
	}

	void RayCasting () {
		RaycastHit hit; 
		float raySum = 0;

		foreach (var ray in rays){
			if(Physics.Raycast(transform.position, ray, out hit)){
				var rayDistance = hit.distance;
				raySum += rayDistance;

				Debug.DrawRay(transform.position, ray * rayDistance, Color.green);
			} else {
				Debug.DrawRay(transform.position, ray * 10, Color.red);
			}
		}
	
		// if (raySum <= 0) {
		// 	return;
		// }

		space = raySum / rays.Count;

		foreach (var visualizer in visualisers) {
			visualizer.thisRenderer.material.SetFloat("_EnvironmentSpace", space);
		}
	}
}
