using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
using System.Linq;
using UnityEngine;

public class CsvVisualizer : MonoBehaviour {
	public TextAsset pathFile, clicksFile;
	public GameObject clickPrefab;
	private List<Vector3> vectors;
	private List<Vector4> clicks;

	void Start () {
		vectors = new List<Vector3>();
		clicks = new List<Vector4>();

		string[] vectorStrings = pathFile.text.Split(new [] {"\r\n"}, StringSplitOptions.RemoveEmptyEntries).Skip(1).ToArray();
		string[] clickStrings = clicksFile.text.Split(new [] {"\r\n"}, StringSplitOptions.RemoveEmptyEntries).Skip(1).ToArray();

		foreach (var str in vectorStrings) {
			var components = str.Split(',');
			var vec = new Vector3(
				float.Parse(components[0]), 
				float.Parse(components[1]), 
				float.Parse(components[2])
			);
			vectors.Add(vec);
		}

		foreach (var str in clickStrings) {
			var components = str.Split(',');
			var position = new Vector4(
				float.Parse(components[0]), 
				float.Parse(components[1]), 
				float.Parse(components[2]), 
				float.Parse(components[3])
			);
			clicks.Add(position);
			Instantiate(clickPrefab, position, Quaternion.identity);
		}
	}

	void Update () {
		float distance = 0;

		for (int i = 0; i < vectors.Count - 1; i++) {
			var from = vectors[i];
			var to = vectors[i + 1];

			distance += (to - from).magnitude;

			Debug.DrawLine(from, to);
		}

		Debug.Log("distance: " + distance);
	}
}
