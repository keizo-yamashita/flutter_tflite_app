import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:tflite_app/utils/logger.dart';
import 'package:tflite_app/tflite/recognition.dart';


/////////////////////////////////////////////////
/// Classifier
/// @param interpreter: Interpreter
/// @param useGPU: bool
/// @param modelName: String
/// @return Future<void>
/////////////////////////////////////////////////

class Classifier {
  Classifier({
    bool?        useGPU,
    String?      modelName,
  }) {
    loadModel(useGPU ?? false, modelName ?? 'yolov5n_float32.tflite');
  }
  late Interpreter? _interpreter;
  Interpreter? get interpreter => _interpreter;

  ImageProcessor?       imageProcessor;
  late int              inputSize;
  late List<List<int>>  outputShapes;
  late TfLiteType       tensorType;
  late List<TfLiteType> outputTypes;
  late Function         decodeOutputsTensor;

  static const int clsNum = 80;
  static const double objConfTh = 0.50;
  static const double clsConfTh = 0.50;

  /////////////////////////////////////////////////
  /// Load Interpreter
  /// @param useGPU: bool
  /// @param modelName: String
  /// @return Future<void>
  /////////////////////////////////////////////////

  Future<void> loadModel(bool useGPU, String modelName) async {
    try {
      // set GPU delegate
      var options = InterpreterOptions();
      if(useGPU){
        final gpuDelegate = GpuDelegate(
          options: GpuDelegateOptions(
            allowPrecisionLoss: true,
            waitType: TFLGpuDelegateWaitType.passive,
            enableQuantization: (modelName == "ssd_mobilenet_uint8.tflite") ? true : false,
          ),
        );
        options.addDelegate(gpuDelegate);
      }else{
        options.threads = 4;
      }

      // load model
      _interpreter = await Interpreter.fromAsset(
        modelName,
        options: options,
      );

      // get input and output tensor
      inputSize  = _interpreter!.getInputTensor(0).shape[1];
      tensorType = _interpreter!.getInputTensors()[0].type;

      // get output tensor      
      outputShapes = [];
      outputTypes  = [];

      for (final tensor in _interpreter!.getOutputTensors()) {
        outputShapes.add(tensor.shape);
        outputTypes.add(tensor.type);
      }

      // set decode function
      if (modelName == 'ssd_mobilenet_uint8.tflite') {
        decodeOutputsTensor = decodeSsdMobilenetOutputsTensor;
      } else {
        decodeOutputsTensor = decodeYoloOutputsTensor;
      }

    } on Exception catch (e) {
      logger.warning(e.toString());
    }
  }

  /////////////////////////////////////////////////
  /// Image Preprocessing 
  /// @param inputImage: TensorImage
  /// @return TensorImage
  /////////////////////////////////////////////////
  
  TensorImage getPreprocessedImage(TensorImage inputImage) {

    final padSize = max(inputImage.height, inputImage.width);

    imageProcessor ??= ImageProcessorBuilder().add(
      ResizeWithCropOrPadOp(
        padSize,
        padSize,
      ),
    ).add(
      ResizeOp(
        inputSize,
        inputSize,
        ResizeMethod.BILINEAR,
      ),
    ).build();
    return imageProcessor!.process(inputImage);
  }

  /////////////////////////////////////////////////
  /// Prediction
  /// @param image: image_lib.Image
  /// @return List<Recognition>
  /////////////////////////////////////////////////

  List<Recognition> predict(image_lib.Image image) {
    
    // if interpreter is null, return empty list
    if (_interpreter == null) {
      return [];
    }

    // convert image to TensorImage and preprocess it
    TensorImage inputImage = getPreprocessedImage(TensorImage.fromImage(image));

    var normalizedTensorBuffer = TensorBuffer.createDynamic(TfLiteType.float32);

    List<int> shape = [inputSize, inputSize, 3];

    // create input tensor
    if (tensorType == TfLiteType.uint8) {
      List<int> normalizedInputImage = [];
      for (var pixel in inputImage.tensorBuffer.getIntList()) {
        normalizedInputImage.add(pixel.toInt());
      }
      normalizedTensorBuffer = TensorBuffer.createDynamic(tensorType);
      normalizedTensorBuffer.loadList(normalizedInputImage, shape: shape);
    } else {
      List<double> normalizedInputImage = [];
      for (var pixel in inputImage.tensorBuffer.getDoubleList()) {
        normalizedInputImage.add(pixel/255);
      }
      normalizedTensorBuffer = TensorBuffer.createDynamic(tensorType);
      normalizedTensorBuffer.loadList(normalizedInputImage, shape: shape);
    }
    final inputs = [normalizedTensorBuffer.buffer];

    // create output tensor
    final List<TensorBufferFloat> outputLocations = List<TensorBufferFloat>.generate(
      outputShapes.length, (index) => TensorBufferFloat(outputShapes[index]),
    );
    final outputs = {
      for (int i = 0; i < outputLocations.length; i++) i: outputLocations[i].buffer,
    };

    // run inference    
    _interpreter!.runForMultipleInputs(inputs, outputs);

    return decodeOutputsTensor(outputs, image.height, image.width);
  }

  //////////////////////////////////////////////////////////
  /// Decode Output Tensor
  /// @param outputTensor: TensorBuffer
  /// @return List<Recognition>
  /// @description: decode output tensor for SSD MobileNet
  //////////////////////////////////////////////////////////
  
  List<Recognition> decodeSsdMobilenetOutputsTensor(Map<int, ByteBuffer> outputs, int transHeight, int transWidth) {
    
    // convert output to List<Recognition>
    Float32List boxesList         = outputs[0]!.asFloat32List();
    Float32List classIdsList      = outputs[1]!.asFloat32List();
    Float32List scoresList        = outputs[2]!.asFloat32List();
    Float32List numDetectionsList = outputs[3]!.asFloat32List();

    int numDetections = numDetectionsList[0].toInt();

    List<Recognition> recognitions = [];
    for (int i = 0; i < numDetections; i++) {
      double y = boxesList[i * 4 + 0];
      double x = boxesList[i * 4 + 1];
      double h = boxesList[i * 4 + 2] - y;
      double w = boxesList[i * 4 + 3] - x;
      Rect rect = Rect.fromLTWH(x*inputSize, y*inputSize, w*inputSize, h*inputSize);
      Rect transformRect = imageProcessor!.inverseTransformRect(rect, transHeight, transWidth);
      if(scoresList[i] < objConfTh) continue;
      recognitions.add(Recognition(i, classIdsList[i].toInt(), scoresList[i], transformRect, false));
    }
    return recognitions;
  }

  /////////////////////////////////////////////////
  /// Decode Output Tensor
  /// @param outputTensor: TensorBuffer
  /// @return List<Recognition>
  /// @description: decode output tensor for YOLOv5
  /////////////////////////////////////////////////
   
  List<Recognition> decodeYoloOutputsTensor(Map<int, ByteBuffer> outputs, int transHeight, int transWidth) {
    Float32List results = outputs[0]!.asFloat32List();
    List<Recognition> recognitions = [];

    for (var i = 0; i < results.length; i += (5 + clsNum)) {
      if (results[i + 4] < objConfTh) continue;

      List<double> clsScores = results.sublist(i + 5, i + 5 + clsNum);
      double maxClsConf = clsScores.reduce(max);
      if (maxClsConf < clsConfTh) continue;

      int cls = clsScores.indexOf(maxClsConf);
      Rect rect = Rect.fromCenter(
        center: Offset(
          results[i] * inputSize,
          results[i + 1] * inputSize,
        ),
        width: results[i + 2] * inputSize,
        height: results[i + 3] * inputSize,
      );
      Rect transformRect = imageProcessor!.inverseTransformRect(rect, transHeight, transWidth);

      recognitions.add(Recognition(i, cls, maxClsConf, transformRect, true));
    }

    return recognitions;
  }
}