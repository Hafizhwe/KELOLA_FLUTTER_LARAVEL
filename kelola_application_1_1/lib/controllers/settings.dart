import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:kelola_application_1_1/constants/constants.dart';

class SettingsController extends GetxController {
  final isLoading = false.obs;
  final token = ''.obs;
  final box = GetStorage();

  Future<void> updateSettings({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;

      // Validate password and confirmPassword
      if (password != confirmPassword) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Passwords do not match',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      var data = {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      };

      var response = await http.put(
        Uri.parse('${url}settings'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${box.read('token')}',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        isLoading.value = false;
        token.value = responseBody['token'];
        box.write('token', token.value);
        Get.snackbar(
          'Success',
          responseBody['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          json.decode(response.body)['message'] ?? 'Update failed',
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
}
