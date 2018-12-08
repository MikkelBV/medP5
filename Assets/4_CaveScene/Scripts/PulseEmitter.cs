using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PulseEmitter : MonoBehaviour {
	public static float distance = 0.0f;

	public int maxDistance = 0;
	public List<Vector3> rays;
	public int speed = 25;
	public bool isVR;
    
	private PulseVisualizer[] visualisers;
	private AudioSource audioSource;
	private bool actionButtonDown = false;

	private CsvLogger<Vector3> positionLogger = new CsvLogger<Vector3>(true, "path", "x,y,z", vec => vec.x + "," + vec.y + "," + vec.z);
	private CsvLogger<Vector4> clickLogger = new CsvLogger<Vector4>("clicks", "x,y,z,t", vec => vec.x + "," + vec.y + "," + vec.z + "," + vec.w);

	void Start () {
		audioSource = GetComponent<AudioSource>();
		visualisers = Object.FindObjectsOfType<PulseVisualizer>();
		distance = maxDistance; 

		positionLogger.StartAsyncLogging();
	}

	void OnApplicationQuit() {
		positionLogger.PrintAndSave();
		clickLogger.PrintAndSave();
	}

	void Update () {
		OVRInput.Update();
		distance += speed * Time.deltaTime;

		bool buttonPressed;

		if (isVR) {
			buttonPressed = OVRInput.Get(OVRInput.Button.One);
		} else {
			buttonPressed = Input.GetMouseButtonDown(0);
		}

		if (buttonPressed && !actionButtonDown && distance > maxDistance) {
				EmitSound(200f, 5f);
				audioSource.Play();
		}

		actionButtonDown = buttonPressed;
		RayCasting();
		positionLogger.Log(transform.position);
	}

	void EmitSound(float freq, float intensity) {
		var pulseOrigin = new Vector4(
			transform.position.x, 
			transform.position.y, 
			transform.position.z, 
			1
		);

		foreach (var visualizer in visualisers) {
			visualizer.thisRenderer.material.SetVector("_Origin", pulseOrigin);
			visualizer.thisRenderer.material.SetFloat("_Frequency", freq);
			visualizer.thisRenderer.material.SetFloat("_Intensity", intensity);
		}

		distance = 0.0f;

		pulseOrigin.w = Time.time;
		clickLogger.Log(pulseOrigin);
	}

	void RayCasting() {
		RaycastHit collision; 
		float raySum = 0;

		foreach (var ray in rays){
			if(Physics.Raycast(transform.position, ray, out collision)) {
				raySum += collision.distance;
				Debug.DrawRay(transform.position, ray * collision.distance, Color.green);
			} else {
				Debug.DrawRay(transform.position, ray * 10, Color.red);
			}
		}

		var space = raySum / rays.Count;

		foreach (var visualizer in visualisers) {
			visualizer.thisRenderer.material.SetFloat("_EnvironmentSpace", space);
		}
	}
}
