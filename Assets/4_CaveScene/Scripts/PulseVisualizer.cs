using UnityEngine;
using System.Collections;

public class PulseVisualizer : MonoBehaviour {
	[HideInInspector]
	public Renderer thisRenderer;
	
	void Start () {
		thisRenderer = transform.GetComponent<Renderer>();
	}
	
	void Update () {
		thisRenderer.material.SetFloat("_Distance", PulseEmitter.distance);
	}
}
