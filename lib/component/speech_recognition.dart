import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class SpeechRecognitionService {
  final String clientId = 'su4sagbgqy';
  final String clientSecret = 'sE5LpSSqn1Dcv7IxAxe5zPDnZ9QhvU04FC8bWs8L';

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;

  Future<void> initRecorder() async {
    if (await Permission.microphone.request().isGranted) {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
    } else {
      throw RecordingPermissionException("Microphone permission not granted");
    }
  }

  Future<String?> startRecording() async {
    if (!_isRecorderInitialized) await initRecorder();

    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/temp.wav';

    await _recorder.startRecorder(toFile: filePath);
    _isRecording = true;

    return filePath;
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _recorder.stopRecorder();
      _isRecording = false;
    }
  }

  Future<String?> recognizeSpeech(String filePath) async {
    File audioFile = File(filePath);
    List<int> audioBytes = audioFile.readAsBytesSync();

    String url = 'https://naveropenapi.apigw.ntruss.com/recog/v1/stt?lang=Kor';
    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/octet-stream',
        'X-NCP-APIGW-API-KEY-ID': clientId,
        'X-NCP-APIGW-API-KEY': clientSecret,
      },
      body: audioBytes,
    );

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      return responseBody['text'];
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }
}
