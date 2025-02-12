import 'package:dio/dio.dart';
import 'package:dio_contact/model/login_model.dart';
import 'package:dio_contact/model/menu_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ApiServices {
  final Dio dio = Dio(BaseOptions(
    validateStatus: (status) {
      return status! < 500; // Izinkan status code di bawah 500
    },
  ));

  final String _baseUrl =
      'https://asia-southeast2-menurestoran-443909.cloudfunctions.net/menurestoran';

  Future<List<Menu>> fetchMenuItems() async {
    try {
      final String fullUrl = '$_baseUrl/data/ramen';
      final response = await dio.get(fullUrl);

      if (response.statusCode == 200 || response.statusCode == 403) {
        print(
            'Response success (status ${response.statusCode}): Data berhasil diambil.');
        print('Response body: ${response.data}');

        // Bersihkan respons dari pesan "Forbidden"
        String responseBody = response.data;
        if (responseBody.startsWith('Forbidden')) {
          responseBody = responseBody.replaceFirst('Forbidden', '').trim();
        }

        // Pastikan responseBody adalah JSON yang valid
        dynamic responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          throw Exception('Gagal mengurai JSON: $e');
        }

        // Akses properti 'data'
        if (responseData.containsKey('data')) {
          final List data = responseData['data'];
          return data.map((item) => Menu.fromJson(item)).toList();
        } else {
          throw Exception('Data tidak ditemukan dalam respons.');
        }
      } else {
        throw Exception(
            'Gagal mengambil data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat mengambil data');
    }
  }

  // ==============================
  // Fungsi untuk POST Data Menu
  // ==============================
  Future<bool> postMenu(Menu menu) async {
    try {
      final String fullUrl = '$_baseUrl/tambah/menu_ramen';
      debugPrint('Request URL: $fullUrl');

      final response = await dio.post(
        fullUrl,
        data: jsonEncode(menu.toJson()), // Mengubah objek Menu menjadi JSON
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Menu berhasil ditambahkan: ${response.data}');
        return true;
      } else {
        debugPrint(
            'Gagal menambahkan menu. Status Code: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Error Response: ${e.response!.data}');
      } else {
        debugPrint('Error: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('Terjadi kesalahan saat menambahkan menu');
    }
  }

  // ==============================
  // Fungsi untuk LOGIN
  // ==============================
Future<LoginResponse?> login(Map<String, dynamic> loginData) async {
  try {
    final String fullUrl = '$_baseUrl/admin/login';
    debugPrint('Request URL: $fullUrl');
    debugPrint('Request Data: ${jsonEncode(loginData)}');

    final response = await dio.post(
      fullUrl,
      data: jsonEncode(loginData),
    );

    debugPrint('Response Status Code: ${response.statusCode}');
    debugPrint('Response Data: ${response.data}');

    // Tambahkan pengecekan status code (200 atau 403)
    if (response.statusCode == 200 || response.statusCode == 403) {
      print(
          'Response success (status ${response.statusCode}): Data berhasil diambil.');
      print('Response body: ${response.data}');

      // Bersihkan respons dari pesan "Forbidden"
      String responseBody = response.data;
      if (responseBody.startsWith('Forbidden')) {
        responseBody = responseBody.replaceFirst('Forbidden', '').trim();
      }

      // Coba mengurai data JSON terlepas dari status code atau tipe respons
      try {
        // Pastikan responseBody adalah JSON yang valid
        dynamic responseData;
        if (responseBody is String) {
          responseData = jsonDecode(responseBody);
        } else {
          responseData = responseBody;
        }

        // Buat objek LoginResponse dari data yang diurai
        final loginResponse = LoginResponse.fromJson(responseData);

        // Jika status login adalah "Login successful", lanjutkan
        if (loginResponse.message == "Login successful") {
          return loginResponse;
        } else {
          displaySnackbar('Login gagal: ${loginResponse.message}');
          return null;
        }
      } catch (e) {
        debugPrint('Error parsing JSON: $e');
        displaySnackbar('Terjadi kesalahan saat mengurai respons dari server.');
        return null;
      }
    } else {
      // Jika status code bukan 200 atau 403, lempar exception
      throw Exception('Gagal melakukan login. Status Code: ${response.statusCode}');
    }
  } on DioException catch (e) {
    debugPrint('DioException - Error: ${e.message}');
    displaySnackbar('Terjadi kesalahan saat menghubungi server.');
    return null;
  } catch (e, stacktrace) {
    debugPrint('Catch Error: $e');
    debugPrint('Stack Trace: $stacktrace');
    throw Exception('Terjadi kesalahan saat login');
  }
}

// Fungsi untuk menampilkan SnackBar
  void displaySnackbar(String message) {
    debugPrint('Snackbar: $message');
    // Implementasikan SnackBar di UI (optional)
  }
}
