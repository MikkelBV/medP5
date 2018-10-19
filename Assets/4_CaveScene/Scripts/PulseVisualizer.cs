using UnityEngine;
using System.Collections;

public class PulseVisualizer : MonoBehaviour {
	public Material pulseMaterial;
	private Renderer renderer;
	
	void Start () {
		renderer = transform.GetComponent<Renderer>();
		renderer.material= pulseMaterial;

		// TODO: this should be done by making materials for each type instead
		switch(gameObject.tag) {
			case "Environment":
				renderer.material.SetFloat("_RimOn", 1);
				renderer.material.SetFloat("_RimPower", 0.6f);
				renderer.material.SetColor("_Color", Color.yellow);
				renderer.material.SetColor("_RimColor", Color.red);
				break;
			case "Water":
				renderer.material.SetFloat("_RimOn", 0);
				renderer.material.SetColor("_Color", Color.blue);
				break;
			case "Plant":
				renderer.material.SetFloat("_RimOn", 1);
				renderer.material.SetColor("_Color", Color.green);
				renderer.material.SetColor("_RimColor", Color.green);
				break;
			default:
				break;
		}
	}
	
	void Update () {
		if(gameObject.GetComponent<Renderer>())
		{
			renderer.material.SetVector("_Origin", PulseEmitter.pulseOrigin);
			renderer.material.SetFloat("_PDistance", PulseEmitter.distance);
			renderer.material.SetFloat("_PFadeDistance", PulseEmitter.fadeDistance);
			renderer.material.SetFloat("_PEdgeSoftness", PulseEmitter.edgeSoftness);			
		}
	}
}
