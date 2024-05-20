import 'package:flutter/material.dart';
import 'package:tflite_app/components/button.dart';
import 'package:tflite_app/components/modal_window.dart';
import 'package:tflite_app/components/style.dart';
import 'package:tflite_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:camera/camera.dart';

import 'package:tflite_app/tflite/recognition.dart';

class DetectionScreen extends HookConsumerWidget {
  DetectionScreen({Key? key}) : super(key: key);

  final List<String> modelList = [
    'coco128_float32.tflite',
    'yolov5n_float32.tflite',
    'yolov5s_float32.tflite',
    'yolov5m_float32.tflite',
    'yolov5l_float32.tflite',
    'ssd_mobilenet_uint8.tflite',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final size = MediaQuery.of(context).size;
    final mlCamera = ref.watch(mlCameraProvider(size));
    final recognitions = ref.watch(recognitionsProvider);
    final useGpu    = ref.watch(settingProvider).useGPU;
    final modelName = ref.watch(settingProvider).modelName;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detection', style: Styles.defaultStyle18),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomTextButton(
                  text: 'Use GPU',
                  backgroundColor: Styles.darkBgColor,
                  enable: useGpu,
                  width: 80,
                  height: 30,
                  onPressed: () async {
                    ref.read(settingProvider).useGPU = !useGpu;
                    ref.read(settingProvider).storePreferences();
                    mlCamera.when(
                      data: (mlCamera) async {
                        mlCamera.changeModel(!useGpu, modelName);
                      },
                      error: (err, stack) => print(err),
                      loading: () => print('loading'),
                    );
                  }
                ),
                CustomTextButton(
                  text: modelName,
                  backgroundColor: Styles.darkBgColor,
                  enable: true,
                  width: 200,
                  height: 30,
                  onPressed: (){
                    showModalWindow(
                      context,
                      0.5,
                      buildModalWindowContainer(
                        context,
                        [
                        for (var model in modelList)
                          Text(
                            model,
                            style: Styles.headlineStyle13,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        0.5,
                        (BuildContext context, int index) {
                          ref.read(settingProvider).modelName = modelList[index];
                          ref.read(settingProvider).storePreferences();
                          mlCamera.when(
                            data: (mlCamera) async {
                              mlCamera.changeModel(!useGpu, modelList[index]);
                            },
                            error: (err, stack) => print(err),
                            loading: () => print('loading'),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: mlCamera.when(
              data: (mlCamera) => Stack(
                children: [
                  CameraView(cameraController: mlCamera.cameraController),
                  buildBoxes(
                    recognitions,
                    mlCamera.actualPreviewSize,
                    mlCamera.ratio,
                  ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Center(
                child: Text(
                  err.toString(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Text("${(ref.watch(settingProvider).predictDurationMs == 0 ? 0 : 1000 / ref.watch(settingProvider).predictDurationMs).toStringAsFixed(2)} FPS", style: Styles.defaultStyle18),
                ),
                Text("  (${ref.watch(settingProvider).predictDurationMs} ms)", style: Styles.defaultStyle18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBoxes(
      List<Recognition> recognitions,
      Size actualPreviewSize,
      double ratio,
      ) {
    if (recognitions.isEmpty) {
      return const SizedBox();
    }

    return Stack(
      children: recognitions.map((result) {
        return BoundingBox(
          result: result,
          actualPreviewSize: actualPreviewSize,
          ratio: ratio,
        );
      }).toList(),
    );
  }
}

class CameraView extends StatelessWidget {
  const CameraView({
    Key? key,
    required this.cameraController,
  }) : super(key: key);
  final CameraController cameraController;
  @override
  Widget build(BuildContext context) {
    return CameraPreview(cameraController);
  }
}

class BoundingBox extends StatelessWidget {
  const BoundingBox({
    Key? key,
    required this.result,
    required this.actualPreviewSize,
    required this.ratio,
  }) : super(key: key);
  final Recognition result;
  final Size actualPreviewSize;
  final double ratio;
  @override
  Widget build(BuildContext context) {
    final renderLocation = result.getRenderLocation(
      actualPreviewSize,
      ratio,
    );
    return Positioned(
      left: renderLocation.left,
      top: renderLocation.top,
      width: renderLocation.width,
      height: renderLocation.height,
      child: Container(
        width: renderLocation.width,
        height: renderLocation.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.primaries[
              result.label % Colors.primaries.length
            ],
            width: 3,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(2),
          ),
        ),
        child: buildBoxLabel(result, context),
      ),
    );
  }

  Align buildBoxLabel(Recognition result, BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: FittedBox(
        child: ColoredBox(
          color: Colors.primaries[
            result.label % Colors.primaries.length
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.displayLabel,
              ),
              Text(
                ' ${result.score.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
