using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerLook : MonoBehaviour {

	private Vector2 mouseDirection; // using a 2D vector since we only need x and y values
	public float mouseSensivity; // variable for determining sensivity of mouse
	private Transform playerObject; // player parent

	// this.transform grabs hold of the transform that this specific script is attached to
	void Start () {
		playerObject = this.transform.parent.transform;
		mouseSensivity = 4; 
	}
		// reads how much the mouse has moved in both the x and y axes in every frame and stores the data in mouseChange
		// quaternions are used to represent rotations (x,y,z,w)
		// AngleAxis takes two arguments, the angle (a float - mouseDirection.y) and which axis we want to rotate around
		// Vector3.right is short for Vector3(1, 0 ,0)
	
	void Update () {
		Vector2 mouseChange = new Vector2(mouseSensivity * Input.GetAxisRaw("Mouse X"), mouseSensivity * Input.GetAxisRaw("Mouse Y"));

		mouseDirection += mouseChange; // adding the movement to overall mouse direction
		mouseDirection.y = Mathf.Clamp(mouseDirection.y, -70, 90);
		
		this.transform.localRotation = Quaternion.AngleAxis(-mouseDirection.y, Vector3.right);
		playerObject.localRotation = Quaternion.AngleAxis(mouseDirection.x, Vector3.up);
	}
}
