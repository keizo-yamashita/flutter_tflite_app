import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as image_lib;

import 'package:tflite_app/tflite/classifier.dart';
import 'package:tflite_app/tflite/image_utils.dart';
import 'package:tflite_app/tflite/recognition.dart';


///////////////////////////////////////////////////////////////////////////////// 
/// MLCamera
/// @param _ref: Ref
/// @param cameraController: CameraController
/// @param cameraViewSize: Size
/// @return MLCamera
///////////////////////////////////////////////////////////////////////////////// 

class MLCamera {

  final CameraController cameraController;

  final Size cameraViewSize;
  late double ratio = Platform.isAndroid
      ? cameraViewSize.width / cameraController.value.previewSize!.height
      : cameraViewSize.width / cameraController.value.previewSize!.height;

  late Size actualPreviewSize = Size(
    cameraViewSize.width,
    cameraViewSize.width * ratio,
  );

  final Ref _ref;
  late Classifier? classifier;

  late Isolate  isolate;
  late SendPort sendPort;
  late ReceivePort receivePort;

  bool isPrepearing    = true;
  bool isPredicting    = false;
  bool enableDetection = true;
  int elapsed          = 0;

  ///////////////////////////////////////////////////////
  /// MLCamera constructor
  /// @param _ref: Ref
  /// @param cameraController: CameraController
  /// @param cameraViewSize: Size
  /// @param useGPU: bool
  /// @param modelName: String
  /// @return MLCamera
  /// @description: MLCamera constructor
  ///////////////////////////////////////////////////////
  
  MLCamera(
    this._ref,
    this.cameraController,
    this.cameraViewSize,
    useGPU,
    modelName,
  ) {
    Future(() async {
      classifier = Classifier(
        useGPU: useGPU,
        modelName: modelName,
      );
      initIsolate();
      await cameraController.startImageStream(onCameraAvailable);
    });
  }

  ///////////////////////////////////////////////////////
  /// initIsolate
  /// @return Future<void>
  /// @description: init isolate
  ///////////////////////////////////////////////////////

  Future<void> initIsolate() async {
    receivePort = ReceivePort();
    isPredicting = false;
    isolate = await Isolate.spawn(entryPoint, receivePort.sendPort);
    sendPort = await receivePort.first as SendPort;
    isPrepearing = false;
  }

  ///////////////////////////////////////////////////////
  /// stopIsolate
  /// @return void
  /// @description: stop isolate
  ///////////////////////////////////////////////////////
  
  void stopIsolate() {
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);
  }

  ///////////////////////////////////////////////////////
  /// entryPoint
  /// @param sendPort: SendPort
  /// @return void
  /// @description: entry point for isolate
  ///////////////////////////////////////////////////////
  
  static void entryPoint(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((message) async {
      final data = message[0] as IsolateData;
      final replyTo = message[1] as SendPort;
      final results = await inference(data);
      replyTo.send(results);
    });
  }

  ///////////////////////////////////////////////////////
  /// changeModel
  /// @param modelName: String
  /// @return void
  /// @description: change model
  ///////////////////////////////////////////////////////
  
  Future<void> changeModel(bool useGPU, String modelName) async {
    isPrepearing = true;
    isPredicting = false;
    stopIsolate();
    classifier = Classifier(
      useGPU:    useGPU,
      modelName: modelName,
    );
    initIsolate();
    isPrepearing = false;
  }

  ///////////////////////////////////////////////////////
  /// onCameraAvailable
  /// @param cameraImage: CameraImage
  /// @return Future<void>
  ///////////////////////////////////////////////////////
  
  Future<void> onCameraAvailable(CameraImage cameraImage) async {

    if (classifier == null) {
      return;
    }

    if (isPredicting) {
      return;
    }

    if (isPrepearing) {
      return;
    }

    isPredicting = true;
    final startTime = DateTime.now();
    final isolateData = IsolateData(
      cameraImage: cameraImage,
      classifier: classifier as Classifier,
    );

    final responsePort = ReceivePort();
    sendPort.send([isolateData, responsePort.sendPort]);
    final result = await responsePort.first
    .timeout(
      const Duration(seconds: 1),
      onTimeout: () {
        return null;
      },
    );
    List<Recognition> recognitions = result ?? [];
    _ref.read(recognitionsProvider.notifier).state = recognitions;

    isPredicting = false;
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    elapsed = duration.inMilliseconds;
    _ref.read(settingProvider).predictDurationMs = duration.inMilliseconds;
  }

  /////////////////////////////////////////////////////////
  /// inference
  /// @param isolateCamImgData: IsolateData
  /// @return Future<List<Recognition>>
  /// @description: inference
  /////////////////////////////////////////////////////////
  
  static Future<List<Recognition>> inference(IsolateData isolateCamImgData) async {
    
    late image_lib.Image image;

    if(isolateCamImgData.classifier == null){
      return [];
    }

    if(isolateCamImgData.cameraImage.format.group == ImageFormatGroup.yuv420){
      image = ImageUtils.convertYUV420ToImage(
        isolateCamImgData.cameraImage,
      );
    }else if(isolateCamImgData.cameraImage.format.group == ImageFormatGroup.bgra8888){
      image = ImageUtils.convertBGRAToImage(
        isolateCamImgData.cameraImage,
      );
    }else{
      image = ImageUtils.convertBGRAToImage(
        isolateCamImgData.cameraImage,
      );
    }
    
    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, 90);
    }

    return isolateCamImgData.classifier!.predict(image);
  }
}

class IsolateData {
  IsolateData({
    required this.cameraImage,
    required this.classifier,
  });
  final CameraImage cameraImage;
  final Classifier? classifier;
}
