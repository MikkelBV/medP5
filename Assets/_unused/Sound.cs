using UnityEngine;
using System.Collections;

public class Sound : MonoBehaviour {
	
	public AudioClip[] pulse;
	private bool playingSound;
	
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () 
	{
		
	}
	
	public void PulseSound(float vol = 0.5f)
	{
		gameObject.GetComponent<AudioSource>().clip = pulse[Random.Range(0, pulse.Length - 1)];
		gameObject.GetComponent<AudioSource>().volume = vol;
		gameObject.GetComponent<AudioSource>().Play();
	}
}
