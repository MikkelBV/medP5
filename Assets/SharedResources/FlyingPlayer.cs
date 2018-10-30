using UnityEngine;
using System.Collections;
 
public class FlyingPlayer : MonoBehaviour {
	public float mouseSensitivity = 10
	;
 	public float moveSpeed = 10;
 
	private Vector2 mouseDirection;

	
	void Update (){
		mouseDirection += new Vector2(mouseSensitivity * Input.GetAxisRaw("Mouse X"), mouseSensitivity * Input.GetAxisRaw("Mouse Y"));
		mouseDirection.y = Mathf.Clamp (mouseDirection.y, -90, 90);
 
		transform.localRotation = Quaternion.AngleAxis(mouseDirection.x, Vector3.up);
		transform.localRotation *= Quaternion.AngleAxis(mouseDirection.y, Vector3.left);

		transform.Translate(moveSpeed * Input.GetAxis("Horizontal") * Time.deltaTime, 0, moveSpeed * Input.GetAxis("Vertical") * Time.deltaTime);
	}
}