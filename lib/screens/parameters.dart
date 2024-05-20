////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

// my package
import 'package:tflite_app/main.dart';
import 'package:tflite_app/components/modal_window.dart';
import 'package:tflite_app/components/style.dart';

class ParametersScreen extends ConsumerStatefulWidget {
  const ParametersScreen({Key? key}) : super(key: key);
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends ConsumerState<ParametersScreen> {
  
  Size screenSize = const Size(0, 0);
  List<String> modelList = [
    'coco128_float32.tflite',
    'yolov5n_float32.tflite',
    'yolov5s_float32.tflite',
    'yolov5m_float32.tflite',
    'yolov5l_float32.tflite',
    'ssd_mobilenet_uint8.tflite',
  ];

  @override
  Widget build(BuildContext context) {
    screenSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height
    );

    bool   enableDarkTheme = ref.watch(settingProvider).enableDarkTheme;
    bool   useGPU    = ref.watch(settingProvider).useGPU;
    bool   isStop    = ref.watch(settingProvider).isStop;
    String modelName = ref.watch(settingProvider).modelName;

    return SafeArea(
        child: SettingsList(
          lightTheme: const SettingsThemeData(
            settingsListBackground: Styles.lightBgColor,
            settingsSectionBackground: Styles.lightColor,
          ),
          darkTheme: const SettingsThemeData(
            settingsListBackground: Styles.darkBgColor,
            settingsSectionBackground: Styles.darkColor,
          ),
          sections: [
            SettingsSection(
              title: Text('基本設定', style: Styles.defaultStyle15),
              tiles: [
                SettingsTile.navigation(
                  leading: Icon(
                    (enableDarkTheme) ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: Text('カラーテーマ', style: Styles.defaultStyle13),
                  value: Text(
                    (enableDarkTheme) ? "ダークテーマ" : "ライトテーマ",
                    style: Styles.defaultStyle13,
                  ),
                  onPressed: (value) {
                    setState(
                      () {
                        showModalWindow(
                          context,
                          0.5,
                          buildModalWindowContainer(
                            context,
                            [
                              Text(
                                "ライトテーマ",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "ダークテーマ",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            0.5,
                            (BuildContext context, int index) {
                              setState(() {});
                              ref.read(settingProvider).enableDarkTheme = index == 1 ? true : false;
                              ref.read(settingProvider).storePreferences();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.calculate_outlined),
                  title: Text('Use Model', style: Styles.defaultStyle13),
                  value: Text(
                    modelName,
                    style: Styles.defaultStyle13,
                  ),
                  onPressed: (value) {
                    setState( 
                      () {
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
                              setState(() {});
                              ref.read(settingProvider).modelName = modelList[index];
                              ref.read(settingProvider).storePreferences();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.calculate_outlined),
                  title: Text('Use GPU', style: Styles.defaultStyle13),
                  value: Text(
                    (useGPU) ? "true" : "false",
                    style: Styles.defaultStyle13,
                  ),
                  onPressed: (value) {
                    setState( 
                      () {
                        showModalWindow(
                          context,
                          0.5,
                          buildModalWindowContainer(
                            context,
                            [
                              Text(
                                "false",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "true",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            0.5,
                            (BuildContext context, int index) {
                              setState(() {});
                              ref.read(settingProvider).useGPU =
                                  index == 1 ? true : false;
                              ref.read(settingProvider).storePreferences();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.calculate_outlined),
                  title: Text('Stanby Mode', style: Styles.defaultStyle13),
                  value: Text(
                    (isStop) ? "true" : "false",
                    style: Styles.defaultStyle13,
                  ),
                  onPressed: (value) {
                    setState( 
                      () {
                        showModalWindow(
                          context,
                          0.5,
                          buildModalWindowContainer(
                            context,
                            [
                              Text(
                                "false",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "true",
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            0.5,
                            (BuildContext context, int index) {
                              setState(() {});
                              ref.read(settingProvider).isStop = index == 1 ? true : false;
                              ref.read(settingProvider).storePreferences();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ), 
    );
  }
}