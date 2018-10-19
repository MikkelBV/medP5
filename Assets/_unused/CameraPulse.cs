using UnityEngine;
using System.Collections;

public class CameraPulse : MonoBehaviour {
	
	public Camera pulseCamera;
	private float sightRadius = 0.0f;
	
	// Use this for initialization
	void Start ()
	{
		GetComponent<Camera>().farClipPlane = 0;
		GetComponent<Camera>().nearClipPlane = sightRadius;
	}
	
	// Update is called once per frame
	void Update ()
	{
		
		if (Input.GetMouseButtonDown(0))
		{
			//pulse = true;
			Camera clone;
			clone = Instantiate (pulseCamera, transform.position, transform.rotation) as Camera;
			clone.transform.parent = transform;
		}
		
		/*if(pulse)
		{
			Camera clone;
			clone = Instantiate (pulseCamera, transform.position, transform.rotation) as Camera;
			clone.transform.parent = transform;
			clone.camera.farClipPlane += 0.1f;
			clone.camera.nearClipPlane = camera.farClipPlane - (3 + camera.farClipPlane*0.25f);
			
			if(clone.camera.farClipPlane >= 50)
			{
				pulse = false;
				clone.camera.farClipPlane = 0;
				clone.camera.nearClipPlane = 0;
			}
		}*/
	}
}
