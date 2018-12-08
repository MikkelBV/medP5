using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Finish : MonoBehaviour {
	private CsvLogger<float> logger = new CsvLogger<float>("completion-time", "t", f => f.ToString()); 

	void OnTriggerEnter(Collider collider) {
		print(Time.realtimeSinceStartup);
		logger.Log(Time.realtimeSinceStartup);
		logger.PrintAndSave();
	}
}
