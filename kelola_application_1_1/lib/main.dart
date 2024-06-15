import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kelola_application_1_1/controllers/auth.dart';
import 'package:kelola_application_1_1/views/dashboard_screen.dart';
import 'package:kelola_application_1_1/views/home_screen.dart';
import 'package:kelola_application_1_1/views/login_screen.dart';
import 'package:kelola_application_1_1/views/register_screen.dart';
import 'package:kelola_application_1_1/views/data_screen.dart';
import 'package:kelola_application_1_1/views/budget_screen.dart';
import 'package:kelola_application_1_1/views/setting_screen.dart';
import 'package:kelola_application_1_1/views/input_screen.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthenticationController _authController =
      Get.put(AuthenticationController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kelola Money Manager',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Obx(() {
        // Check if the user is authenticated and navigate accordingly
        return _authController.token.value.isNotEmpty
            ? SplashScreen()
            : LoginScreen();
      }),
      getPages: [
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/dashboard', page: () => Dashboard()),
        GetPage(name: '/input', page: () => InputForm()),
        GetPage(name: '/transaksi', page: () => DataScreen()),
        GetPage(name: '/budget', page: () => Budget()),
        GetPage(name: '/setting', page: () => SettingsUser()),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        Get.offAllNamed('/login');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Image.asset(
                'images/Splash Screen.png',
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
