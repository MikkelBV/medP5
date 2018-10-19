using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundEmitter_ParticleConcept : MonoBehaviour {
	public ParticleSystem part;

	void Update() {
		if(Input.GetMouseButtonDown(0)) {
			part.Play();
		}
	}
}
