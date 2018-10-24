using UnityEngine;
using System.Collections;

public class PulseEmitter : MonoBehaviour {
	public static float distance = 0.0f;
	public static float fadeDistance;
	public static float edgeSoftness;

	public int speed = 8;

	void Start () {
		fadeDistance = 5f;
		edgeSoftness = 5f;
	}

	void Update () {
		distance += speed * Time.deltaTime;

		if (Input.GetMouseButtonDown(0)){
			EmitSound(50f, 0.3f);
		} else if (Input.GetMouseButtonDown(1)) {
			EmitSound(12, 8f);
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
