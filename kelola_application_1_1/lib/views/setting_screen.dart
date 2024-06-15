import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kelola_application_1_1/controllers/settings.dart';
import 'package:kelola_application_1_1/controllers/auth.dart';

class SettingsUser extends StatefulWidget {
  @override
  _SettingsUserState createState() => _SettingsUserState();
}

class _SettingsUserState extends State<SettingsUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final SettingsController _settingsController = Get.put(SettingsController());
  final AuthenticationController _authController =
      Get.put(AuthenticationController());

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers with current user data if available
    var currentUser = _authController.box.read('user');
    if (currentUser != null) {
      _usernameController.text = currentUser['username'];
      _emailController.text = currentUser['email'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Background 2.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Form Box with Scrollable Content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCustomTextField(
                              controller: _usernameController,
                              hintText: 'Username',
                              backgroundColor: Colors.grey[200],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            _buildCustomTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              backgroundColor: Colors.grey[200],
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            _buildCustomTextField(
                              controller: _passwordController,
                              hintText: 'New Password',
                              obscureText: true,
                              backgroundColor: Colors.grey[200],
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    value.length < 8) {
                                  return 'Password must be at least 8 characters long';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            _buildCustomTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm New Password',
                              obscureText: true,
                              backgroundColor: Colors.grey[200],
                              validator: (value) {
                                if (_passwordController.text.isNotEmpty &&
                                    value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 30),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _settingsController.updateSettings(
                                      username: _usernameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text.isEmpty
                                          ? ''
                                          : _passwordController.text,
                                      confirmPassword:
                                          _confirmPasswordController.text,
                                    );
                                  }
                                },
                                child: Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        await _authController.logout();
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Color? backgroundColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }
}
