using UnityEngine;
using System.Collections;

public class PulseEmitter : MonoBehaviour {
	public static float distance = 0.0f;
	public static float fadeDistance;
	public static float edgeSoftness;

	public int speed = 25;

	void Start () {
		fadeDistance = 5f;
		edgeSoftness = 5f;
	}

	void Update () {
		distance += speed * Time.deltaTime;
		Debug.Log(distance);

		if (Input.GetMouseButtonDown(0)){
			EmitSound(100f, 8f);
		} else if (Input.GetMouseButtonDown(1)) {
			EmitSound(20f, 2f);
		}
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
}
