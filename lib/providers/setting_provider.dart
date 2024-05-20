////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider extends ChangeNotifier {
  
  bool _enableDarkTheme = true;

  bool isEditting = false;
  bool isRotating = false;
  
  double _screenPaddngTop = 0.0;
  double _screenPaddngBottom = 0.0;
  double _appBarHeight = 0.0;
  double _navigationBarHeight = 0.0;
  
  // for detection
  bool   _isStop = false;
  bool   _useGPU = false;
  int?   _predictDurationMs = 0;
  String _modelName = 'yolov5n_float32.tflite';

  bool get enableDarkTheme  => _enableDarkTheme;
 
  double get screenPaddingTop    => _screenPaddngTop;
  double get screenPaddingBottom => _screenPaddngBottom;
  double get appBarHeight        => _appBarHeight;
  double get navigationBarHeight => _navigationBarHeight;

  // for detection
  bool   get useGPU => _useGPU;
  bool   get isStop => _isStop;
  int    get predictDurationMs => _predictDurationMs ?? 0;
  String get modelName => _modelName;

  set enableDarkTheme(bool result) {
    _enableDarkTheme = result;
    notifyListeners();
  }

  set useGPU(bool result) {
    _useGPU = result;
    notifyListeners();
  }

  set isStop(bool result) {
    _isStop = result;
    notifyListeners();
  }

  set predictDurationMs(int result) {
    _predictDurationMs = result;
    notifyListeners();
  }

  set modelName(String result) {
    _modelName = result;
    notifyListeners();
  }

  set screenPaddingTop(double paddingTop) {
    _screenPaddngTop = paddingTop;
    notifyListeners();
  }

  set screenPaddingBottom(double paddingBottom) {
    _screenPaddngBottom = paddingBottom;
    notifyListeners();
  }

  set appBarHeight(double appBarHeight){
    _appBarHeight = appBarHeight;
    notifyListeners();
  }

  set navigationBarHeight(double navigationBarHeight) {
    _navigationBarHeight = navigationBarHeight;
    notifyListeners();
  }

  Future loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _enableDarkTheme = prefs.getBool('enableDarkTheme') ?? true;
    _useGPU = prefs.getBool('useGPU') ?? false;
    _isStop = prefs.getBool('isStop') ?? false;
    _modelName = prefs.getString('modelName') ?? 'yolov5n_float32.tflite';
    notifyListeners();
  }

  Future storePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enableDarkTheme', _enableDarkTheme);
    prefs.setBool('useGPU', _useGPU);
    prefs.setBool('isStop', _isStop);
    prefs.setString('modelName', _modelName);
    notifyListeners();
  }
}
