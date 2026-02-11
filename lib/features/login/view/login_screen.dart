import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/text_const.dart';
import '../../../core/constants/image_const.dart';
import '../controller/login_controller.dart';
import '../../home/view/home_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  void _handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final controller = context.read<LoginController>();
      final success = await controller.login();

      if (success && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else if (context.mounted) {
        final error = controller.error;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error ?? 'Login failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginController>(
        builder: (context, controller, child) {
          return Stack(
            children: [
              // Background Image + Blur Header
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Stack(
                  children: [
                    /// Background Image
                    Positioned.fill(
                      child: Image.asset(
                        ImageConst.background,
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// Blur Overlay
                    Positioned.fill(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                          child: Container(
                            color: Colors.black.withOpacity(
                              0.4,
                            ), // dark tint for readability
                          ),
                        ),
                      ),
                    ),

                    /// Logo
                    Center(child: Image.asset(ImageConst.logo, height: 100)),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TextConst.login['title']!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(TextConst.login['username']!),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.usernameController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your username',
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Please enter username'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            Text(TextConst.login['password']!),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Enter your password',
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Please enter password'
                                  : null,
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () => _handleLogin(context),
                                child: controller.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(TextConst.login['button']!),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'By continuing, you agree to our ',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
