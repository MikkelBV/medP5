using UnityEngine;
using System.Collections;

public class PulseProperties : MonoBehaviour {
	
	private Vector3 startLoc;
	private Vector3 currentLoc;
	
	// Use this for initialization
	void Start ()
	{
		startLoc = transform.position;
		GetComponent<Camera>().depth = GameObject.FindGameObjectsWithTag("PulseCamera").Length;
		GetComponent<Camera>().layerCullSpherical = true;
	}
	
	// Update is called once per frame
	void Update ()
	{
		currentLoc = transform.position;
		GL.Clear (false, true, new Color(0, 0, 0, 0));
		GetComponent<Camera>().farClipPlane += 1*Time.deltaTime - (Vector3.Magnitude(currentLoc - startLoc));
		startLoc = currentLoc;
		GetComponent<Camera>().nearClipPlane = GetComponent<Camera>().farClipPlane - (1);
		
		if(GetComponent<Camera>().farClipPlane >= 50)
		{
			Destroy (gameObject);
			//pulse = false;
			//camera.farClipPlane = 0;
			//camera.nearClipPlane = 0;
		}
	}
}
