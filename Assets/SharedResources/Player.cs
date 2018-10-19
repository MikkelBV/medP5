using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour {
	public float mouseSensivity;
	public float moveSpeed;
	public GameObject head;

	private Vector2 mouseDirection;

	
	void Update () {
		/*
		 * Use mouse to look around
		 */
		mouseDirection += new Vector2(mouseSensivity * Input.GetAxisRaw("Mouse X"), mouseSensivity * Input.GetAxisRaw("Mouse Y"));
		mouseDirection.y = Mathf.Clamp(mouseDirection.y, -70, 90);
		
		head.transform.localRotation = Quaternion.AngleAxis(-mouseDirection.y, Vector3.right);
		transform.localRotation = Quaternion.AngleAxis(mouseDirection.x, Vector3.up);
		///////////////////////////////////////////

		/*
		 * Use WASD to move around
		 */
		transform.Translate(moveSpeed * Input.GetAxis("Horizontal") * Time.deltaTime, 0, moveSpeed * Input.GetAxis("Vertical") * Time.deltaTime);
		///////////////////////////////////////////
	}
}
