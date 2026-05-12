import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';

void main() {
  test('TFLite Model Shape', () async {
    final modelPath = 'assets/yamnet_assets/yamnet.tflite';
    final file = File(modelPath);
    if (!file.existsSync()) {
      print('Model not found at $modelPath');
      return;
    }
    
    final interpreter = Interpreter.fromFile(file);
    final inputTensors = interpreter.getInputTensors();
    final outputTensors = interpreter.getOutputTensors();
    
    print('INPUT TENSORS:');
    for (var t in inputTensors) {
      print('Name: ${t.name}, Shape: ${t.shape}, Type: ${t.type}');
    }
    
    print('OUTPUT TENSORS:');
    for (var t in outputTensors) {
      print('Name: ${t.name}, Shape: ${t.shape}, Type: ${t.type}');
    }
  });
}
