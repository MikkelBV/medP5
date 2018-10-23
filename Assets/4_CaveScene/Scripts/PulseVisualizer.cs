using UnityEngine;
using System.Collections;

public class PulseVisualizer : MonoBehaviour {
	public Material pulseMaterial;

	[HideInInspector]
	public Renderer thisRenderer;
	
	void Start () {
		thisRenderer = transform.GetComponent<Renderer>();
		thisRenderer.material= pulseMaterial;

		// TODO: this should be done by making materials for each type instead
		switch(gameObject.tag) {
			case "Environment":
				thisRenderer.material.SetFloat("_RimOn", 1);
				thisRenderer.material.SetFloat("_RimPower", 0.6f);
				thisRenderer.material.SetColor("_Color", Color.yellow);
				thisRenderer.material.SetColor("_RimColor", Color.red);
				break;
			case "Water":
				thisRenderer.material.SetFloat("_RimOn", 0);
				thisRenderer.material.SetColor("_Color", Color.blue);
				break;
			case "Plant":
				thisRenderer.material.SetFloat("_RimOn", 1);
				thisRenderer.material.SetColor("_Color", Color.green);
				thisRenderer.material.SetColor("_RimColor", Color.green);
				break;
			default:
				break;
		}
	}
	
	void Update () {
		thisRenderer.material.SetFloat("_PDistance", PulseEmitter.distance);
		thisRenderer.material.SetFloat("_PFadeDistance", PulseEmitter.fadeDistance);		
	}
}
