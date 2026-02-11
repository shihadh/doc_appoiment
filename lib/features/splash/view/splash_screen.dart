import 'package:flutter/material.dart';
import '../../../core/constants/image_const.dart';
import '../../login/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImageConst.background),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black54,
            child: Center(child: Image.asset(ImageConst.logo, height: 150)),
          ),
        ],
      ),
    );
  }
}
