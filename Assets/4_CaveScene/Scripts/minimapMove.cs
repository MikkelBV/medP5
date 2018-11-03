using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class minimapMove : MonoBehaviour {
	public GameObject Player;

	void Start () {

	}
	
	void Update () {
		transform.position = new Vector3(Player.transform.position.x,
										 Player.transform.position.y+30,
										 Player.transform.position.z);
	}
} 
