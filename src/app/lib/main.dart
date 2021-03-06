//flutter packages
// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//project internal services / dependency injection
import 'service_locator.dart';
import 'package:imu_tracker/services/localstorage_service.dart';

//screens
import 'package:imu_tracker/screens/qr_code_registration_screen.dart';
import 'screens/main_page.dart';

final androidConfig = FlutterBackgroundAndroidConfig(
  notificationTitle: "security-motion-tracker",
  notificationText: "Security Tracker is running in background",
  notificationImportance: AndroidNotificationImportance.Default,
  notificationIcon: AndroidResource(
      name: 'background_icon',
      defType: 'drawable'), // Default is ic_launcher from
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await setupLocator();

    await FlutterBackground.initialize(androidConfig: androidConfig);
    await FlutterBackground.enableBackgroundExecution();

    runApp(MyApp());
  } catch (error) {
    print('Locator setup has failed');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'IMU_Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoadPage());
  }
}

class LoadPage extends StatefulWidget {
  //LoadPage({Key key}) : super(key: key);
  @override
  LoadPageState createState() => LoadPageState();
}

class LoadPageState extends State {
  bool deviceIsRegistered = false;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light));

    super.initState();
    loadNewLaunch();
  }

  loadNewLaunch() async {
    bool _deviceIsRegistered = LocalStorageService.getDeviceIsRegistered();
    setState(() {
      if (_deviceIsRegistered == Null) {
        _deviceIsRegistered = false;
      }
      deviceIsRegistered = _deviceIsRegistered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            deviceIsRegistered ? const MainPage() : const RegistrationScreen());
  }
}
