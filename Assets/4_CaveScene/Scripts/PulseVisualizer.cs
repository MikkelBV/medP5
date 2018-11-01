using UnityEngine;
using System.Collections;

public class PulseVisualizer : MonoBehaviour {
	public Material pulseMaterial;
	public Texture2D normalMap;

	[HideInInspector]
	public Renderer thisRenderer;
	
	void Start () {
		thisRenderer = transform.GetComponent<Renderer>();
		thisRenderer.material= pulseMaterial;
	}
	
	void Update () {
		thisRenderer.material.SetFloat("_Distance", PulseEmitter.distance);
	}
}
