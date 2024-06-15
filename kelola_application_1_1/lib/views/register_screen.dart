import 'package:flutter/material.dart';
import 'package:kelola_application_1_1/controllers/auth.dart';
import 'package:get/get.dart';
import 'package:kelola_application_1_1/views/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthenticationController _authenticationController =
      Get.put(AuthenticationController());

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    } else if (!GetUtils.isEmail(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi harus diisi';
    } else if (value.length < 8) {
      return 'Kata sandi harus memiliki setidaknya 8 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/Background1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: Image.asset(
                    'images/Logo Kelola.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                Positioned(
                  top: 70,
                  right: 20,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 150,
                  left: 30,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Register\n',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Selamat datang\ndi Kelola - Money Manager',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 260,
                  left: 0,
                  right: 0,
                  bottom: -5,
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(140, 226, 218, 0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 290,
                  left: 25,
                  right: 25,
                  bottom: 6,
                  child: Container(
                    width: double.infinity,
                    height: 380,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCustomTextField(
                            controller: _nameController,
                            hintText: 'Full Name',
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 20),
                          _buildCustomTextField(
                            controller: _usernameController,
                            hintText: 'Username',
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 20),
                          _buildCustomTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 20),
                          _buildCustomTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            obscureText: true,
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 20),
                          _buildCustomTextField(
                            controller: _confirmpasswordController,
                            hintText: 'Confirm Password',
                            obscureText: true,
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                // Panggil fungsi register hanya jika semua bidang telah diisi
                                bool isSuccess =
                                    await _authenticationController.register(
                                  fullname: _nameController.text.trim(),
                                  username: _usernameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  confirmpassword:
                                      _confirmpasswordController.text.trim(),
                                );
                                if (isSuccess) {
                                  // Delayed navigation to the login screen
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    // Navigasi ke halaman login
                                    Get.offAll(() => LoginScreen());
                                  });
                                } else {
                                  // Tampilkan pesan kesalahan jika pendaftaran gagal
                                  String? errorMessage =
                                      _authenticationController.errorMessage;
                                  if (errorMessage != null) {
                                    // Tampilkan pesan kesalahan sebagai snackbar
                                    Get.snackbar(
                                      'Error',
                                      errorMessage,
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              },
                              child: Obx(() {
                                return _authenticationController.isLoading.value
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Register',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Color? backgroundColor,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bidang harus diisi';
          }
          return null;
        },
      ),
    );
  }
}
