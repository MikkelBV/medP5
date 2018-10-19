using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class ParticleHandler : MonoBehaviour {
	public ParticleSystem part;
	public GameObject spawnableLight;

	void OnParticleCollision(GameObject other) {
		List<ParticleCollisionPoint> collisionPoints = part.GetComponent<SoundEmitter_ParticleBounceConcept>().collisionPoints;
		var point = collisionPoints.Last();

		Instantiate(spawnableLight, point.pointOfContact, Quaternion.identity);
	}
}
