
////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tflite_app/providers/deep_link_mixin.dart';
import 'package:tflite_app/components/style.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
 
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> with DeepLinkMixin{
  
  // URL からアクセする場合の画面遷移
  @override
  void onDeepLinkNotify(Uri? uri) {  
    String? parameter = uri!.queryParameters['id'];
    
    if(parameter != null){
      context.go('/parameters/$parameter');
    }
    setState(() {});
  }

  splashScreenTimer(){
    Timer(const Duration(milliseconds: 1000), () async{
      context.go('/viewer');
    });
  }

  @override
  void initState() {
    super.initState();
    splashScreenTimer();
  }

  @override
  Widget build(BuildContext context){

    // 画面の向きを縦方向に固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Material(
      child: Container(
        decoration: Styles.gradientDecolation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Image.asset("assets/logo/logo.png",),
          ),
        ),
      ),
    );
  }
}