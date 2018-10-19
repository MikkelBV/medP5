using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundEmitter_ParticleBounceConcept : MonoBehaviour {
	public List<ParticleCollisionEvent> collisionEvents = new List<ParticleCollisionEvent>();
	public List<ParticleCollisionPoint> collisionPoints = new List<ParticleCollisionPoint>();
	
	private ParticleSystem part;

	void Start() {
		part = GetComponent<ParticleSystem>();
	}

	void Update() {
		if(Input.GetMouseButtonDown(0)) {
			part.Play();
		}
	}

	void OnParticleCollision(GameObject other) {
		if (other.tag == "Player") {
			return;
		}

		int numCollisionEvents = part.GetCollisionEvents(other, collisionEvents);
		if (numCollisionEvents == 1) {
			var point = new ParticleCollisionPoint() { 
				pointOfContact = collisionEvents[numCollisionEvents - 1].intersection,
				collisionObject = other
			};

			collisionPoints.Add(point);
		}
	}
}
