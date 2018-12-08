using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System;
using System.Threading;
using UnityEngine;

public class CsvLogger<T> {
	private Func<T, string> stringParser;
	private Queue<T> logItems = new Queue<T>();
	private string filePath;
	private string fileHeader;

	private bool logAsync = false;
	private volatile bool shouldLog = false;
	private Thread datalogger;

	public CsvLogger(string fileName, string _fileHeader, Func<T, string> _stringParser) 
	: this(false, fileName, _fileHeader, _stringParser) { }

	public CsvLogger(bool _logAsync, string fileName, string _fileHeader, Func<T, string> _stringParser) {
		stringParser = _stringParser;
		fileHeader = _fileHeader;

		string date = DateTimeOffset.Now.ToString("s").Replace(':', '_');
		filePath = "./Logs/" + fileName + "_" + date + ".csv";

		if (_logAsync) {
			logAsync = true;
			shouldLog = true;
		} else {
			logAsync = false;
		}
	}

	public void Log(T item) {
		logItems.Enqueue(item);
	}

	public void PrintAndSave() {
		if (logAsync) {
			shouldLog = false;
			return;
		}

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

	public void StartAsyncLogging() {
		datalogger = new Thread(LogToFileAsync);
		datalogger.Start();
	}

	private void LogToFileAsync() {
		using(StreamWriter file = new StreamWriter(filePath)) {
			file.WriteLine(fileHeader);
			file.Flush();

			while(shouldLog) {
				if (logItems.Count > 0) {
					var item = logItems.Dequeue();
					var str = stringParser(item);
					file.WriteLine(str);
					file.Flush();
				}
			}
		}
	}
}
