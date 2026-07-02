import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> readText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer();
    final result = await recognizer.processImage(inputImage);
    await recognizer.close();
    return result.text;
  }
}