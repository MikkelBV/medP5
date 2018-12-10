using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VRPlayer : MonoBehaviour {
	private CharacterController controller;
	private CsvLogger<Vector4> collisionLogger = new CsvLogger<Vector4>("collisions", "x,y,z,t", vec => vec.x + "," + vec.y + "," + vec.z + "," + vec.w);
    private float timer;

	void Start () {
		controller = GetComponent<CharacterController>();
        timer = 2.0f;
	}

	void OnApplicationQuit() {
		collisionLogger.PrintAndSave();
	}
	
	// Update is called once per frame
	void Update () {
        timer -= Time.deltaTime;

        if (timer < 0)
        {
            if ((controller.collisionFlags & CollisionFlags.Sides) != 0)
            {
                timer = 2.0f;
                Debug.Log("Collide with wall.");

                Vector4 point = new Vector4(
                    transform.position.x,
                    transform.position.y,
                    transform.position.z,
                    Time.time
                    );

                collisionLogger.Log(point);
            }
        }
	}
}
