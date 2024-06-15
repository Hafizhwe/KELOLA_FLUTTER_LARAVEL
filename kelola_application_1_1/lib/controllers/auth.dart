import 'dart:convert';
import 'package:kelola_application_1_1/constants/constants.dart';
import 'package:kelola_application_1_1/views/home_screen.dart';
import 'package:kelola_application_1_1/views/login_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationController extends GetxController {
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final token = ''.obs;
  final box = GetStorage();

  String? get errorMessage => null;

  Future<bool> register({
    required String fullname,
    required String username,
    required String email,
    required String password,
    required String confirmpassword,
  }) async {
    try {
      isLoading.value = true;

      List<String> errors = [];

      // Validasi form kosong
      if (fullname.isEmpty ||
          username.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          confirmpassword.isEmpty) {
        Get.snackbar(
          'ATTENTION !',
          'FORM TIDAK BOLEH KOSONG !!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(255, 228, 223, 71),
          colorText: const Color.fromARGB(255, 0, 0, 0),
        );
        isLoading.value = false;
        return false;
      }

      // Validasi email
      if (!email.contains('@')) {
        errors.add('Email tidak valid');
      } else {
        // Periksa apakah email sudah terdaftar
        var emailCheckResponse = await http.get(
          Uri.parse('${url}check_email?email=$email'),
          headers: {'Accept': 'application/json'},
        );
        if (emailCheckResponse.statusCode == 200) {
          bool isEmailTaken = json.decode(emailCheckResponse.body)['taken'];
          if (isEmailTaken) {
            errors.add('Email sudah terdaftar');
          }
        }
      }

      // Validasi password
      if (password.length < 8) {
        errors.add('Password harus minimal 8 karakter');
      }

      // Validasi konfirmasi password
      if (password != confirmpassword) {
        errors.add('Konfirmasi password harus sama dengan password');
      }

      // Jika ada error, tampilkan notifikasi
      if (errors.isNotEmpty) {
        for (String error in errors) {
          Get.snackbar(
            'Failed!',
            error,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        isLoading.value = false;
        return false;
      }

      var data = {
        'fullname': fullname,
        'username': username,
        'email': email,
        'password': password,
        'confirm-password': confirmpassword,
      };

      var response = await http.post(
        Uri.parse('${url}register'),
        headers: {
          'Accept': 'application/json',
        },
        body: data,
      );

      if (response.statusCode == 201) {
        isLoading.value = false;
        token.value = json.decode(response.body)['token'];
        box.write('token', token.value);
        Get.snackbar(
          'Success',
          'Pendaftaran berhasil',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAll(() => LoginScreen());
        });
        return true;
      } else {
        isLoading.value = false;
        String errorMessage = json.decode(response.body)['message'];
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print(errorMessage);
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      print(e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      var data = {
        'username': username,
        'password': password,
      };

      var response = await http.post(
        Uri.parse('${url}login'),
        headers: {
          'Accept': 'application/json',
        },
        body: data,
      );

      if (username.isEmpty || password.isEmpty) {
        Get.snackbar(
          'ATTENTION !',
          'FORM TIDAK BOLEH KOSONG !!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(255, 228, 223, 71),
          colorText: const Color.fromARGB(255, 0, 0, 0),
        );
        isLoading.value = false;
        return false;
      }

      if (response.statusCode == 200) {
        token.value = json.decode(response.body)['token'];
        box.write('token', token.value);
        isLoggedIn.value = true; // Set isLoggedIn to true upon successful login
        return true; // Return true to indicate successful login
      } else if (response.statusCode == 401) {
        return false; // Return false to indicate invalid credentials
      } else {
        // Handle other error cases
        print('Login failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      print('Error during login: $e');
      Get.snackbar(
        'Error',
        'An error occurred. Please try again later.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      var response = await http.post(
        Uri.parse('${url}logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${token.value}',
        },
      );

      if (response.statusCode == 200) {
        isLoading.value = false;
        box.erase();
        token.value = '';
        Get.offAll(() => LoginScreen());
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          json.decode(response.body)['message'] ?? 'Logout failed',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print(json.decode(response.body));
      }
    } catch (e) {
      isLoading.value = false;
      print(e.toString());
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Cek apakah pengguna sudah login sebelumnya saat aplikasi dimulai
    isLoggedIn.value = box.read('token') != null;
  }
}
