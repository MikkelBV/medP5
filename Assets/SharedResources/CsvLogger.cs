using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System;

public class CsvLogger<T> {
	private Func<T, string> stringParser;
	private List<T> logItems = new List<T>();
	private string filePath;
	private string fileHeader;

	public CsvLogger(string fileName, string _fileHeader, Func<T, string> _stringParser) {
		stringParser = _stringParser;
		fileHeader = _fileHeader;

		string date = DateTimeOffset.Now.ToString("s").Replace(':', '_');
		filePath = fileName + "_" + date + ".csv";
	}

	public void Log(T item) {
		logItems.Add(item);
	}

	public void PrintAndSave() {
		using(StreamWriter file = new StreamWriter(filePath)) {
			file.WriteLine(fileHeader);
			file.Flush();

			foreach(var item in logItems) {
				var str = stringParser(item);
				file.WriteLine(str);
				file.Flush();
			}
		}
	}
}
