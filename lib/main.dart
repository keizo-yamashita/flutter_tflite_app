////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

// my screens
import 'package:tflite_app/app_navigation_bar.dart';
import 'package:tflite_app/screens/detection.dart';
import 'package:tflite_app/screens/splash.dart';
import 'package:tflite_app/screens/parameters.dart';

// my components
import 'package:tflite_app/components/style.dart';
import 'package:tflite_app/providers/deep_link_mixin.dart';
import 'package:tflite_app/providers/setting_provider.dart';
import 'package:tflite_app/tflite/recognition.dart';
import 'package:tflite_app/tflite/ml_camera.dart';


final settingProvider  = ChangeNotifierProvider((ref) => SettingProvider());
final deepLinkProvider = ChangeNotifierProvider((ref) => DeepLinkProvider());

final recognitionsProvider = StateProvider<List<Recognition>>((ref) => []);

final mlCameraProvider = FutureProvider.autoDispose.family<MLCamera, Size>((ref, size) async {
  final cameras = await availableCameras();
  final cameraController = CameraController(
    cameras[0],
    ResolutionPreset.low,
    enableAudio: false,
  );
  await cameraController.initialize();
  final mlCamera = MLCamera(
    ref,
    cameraController,
    size,
    ref.read(settingProvider).useGPU,
    ref.read(settingProvider).modelName,
  );
  return mlCamera;
});

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider   = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      if (state.uri.path == '/splash') {
        return null;
      }
      return;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder:(context, state, navigationShell){
          return AppNavigationBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes:[
              GoRoute(
                name: 'viewer',
                path: '/viewer',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: DetectionScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes:[
              GoRoute(
                name: 'parameters',
                path: '/parameters',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ParametersScreen(),
                ),
              ),
            ],
          ),
        ]
      ),
      GoRoute(
      name: 'spalash',
      path: '/splash',
      pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
    ],
  );
},);


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}
class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingProvider).appBarHeight = AppBar().preferredSize.height;
      ref.read(settingProvider).navigationBarHeight = 56.0;
      ref.read(settingProvider).screenPaddingTop = MediaQuery.of(context).padding.top;
      ref.read(settingProvider).screenPaddingBottom = MediaQuery.of(context).padding.bottom;
      WidgetsBinding.instance.addObserver(this);
    },);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    ref.read(settingProvider).isRotating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingProvider).appBarHeight = AppBar().preferredSize.height;
      ref.read(settingProvider).navigationBarHeight = 56.0;
      ref.read(settingProvider).screenPaddingTop = MediaQuery.of(context).padding.top;
      ref.read(settingProvider).screenPaddingBottom = MediaQuery.of(context).padding.bottom;
      ref.read(settingProvider).isRotating = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    ref.read(settingProvider).loadPreferences();
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(settingProvider).enableDarkTheme;

    return MaterialApp.router(
      title: 'YOLOv5',
      theme: ThemeData(
        scaffoldBackgroundColor: Styles.lightBgColor,
        primaryColor: Styles.primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Styles.lightColor,
          elevation: 0.4,
          scrolledUnderElevation: 0.4,
          shadowColor: Colors.black,
        ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.black,
          brightness: Brightness.light,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Styles.lightColor,
          selectedItemColor: Styles.primaryColor,
          unselectedItemColor: Colors.grey,
        ),
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Styles.darkBgColor,
        primaryColor: Styles.primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Styles.darkColor,
          elevation: 0.4,
          scrolledUnderElevation: 0.4,
          shadowColor: Color(0xFF8C8C8C),
        ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.white,
          brightness: Brightness.dark,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Styles.darkColor,
          selectedItemColor: Styles.primaryColor,
          unselectedItemColor: Styles.hiddenColor,
        ),
        brightness: Brightness.dark,
        
      ),
      
      themeMode: (isDark) ? ThemeMode.dark : ThemeMode.light,
      
      debugShowCheckedModeBanner: false,
      localizationsDelegates:const  [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', ''),],

      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    );
  }
}