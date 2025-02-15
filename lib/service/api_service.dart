import 'package:dio/dio.dart';
import 'package:dio_contact/model/login_model.dart';
import 'package:dio_contact/model/menu_model.dart';
import 'package:dio_contact/model/pesanan_model.dart';
import 'package:dio_contact/model/pesananbaru_model.dart';
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

  Future<List<PesananbaruModel>> fetchDataPesanan(String status) async {
    try {
      final String fullUrl = '$_baseUrl/data/bystatus/flutter?status=$status';
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
          return data.map((item) => PesananbaruModel.fromJson(item)).toList();
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
  Future<MenuResponse?> postMenu(MenuInput ct) async {
    try {
      final response = await dio.post(
        '$_baseUrl/tambah/menu_ramen',
        data: ct.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 403) {
        String responseBody = response.data.toString();
        if (responseBody.startsWith('Forbidden')) {
          responseBody = responseBody.replaceFirst('Forbidden', '').trim();
        }

        dynamic responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          throw Exception('Gagal mengurai JSON: $e');
        }

        debugPrint('Response Data: $responseData');

        if (responseData != null && responseData is Map<String, dynamic>) {
          return MenuResponse.fromJson(responseData);
        } else {
          throw Exception('Gagal menambahkan menu. Data tidak valid.');
        }
      } else {
        throw Exception(
            'Gagal menambahkan menu. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
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
          displaySnackbar(
              'Terjadi kesalahan saat mengurai respons dari server.');
          return null;
        }
      } else {
        // Jika status code bukan 200 atau 403, lempar exception
        throw Exception(
            'Gagal melakukan login. Status Code: ${response.statusCode}');
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

  Future<Menu?> getMenuById(String id) async {
    try {
      final response = await dio.get(
        '$_baseUrl/menu/byid',
        queryParameters: {'id': id},
      );

      // Cek status code
      if (response.statusCode == 200 || response.statusCode == 403) {
        // Bersihkan respons dari pesan "Forbidden"
        String responseBody = response.data.toString();
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

        // Debug: Cetak respons untuk memastikan data diterima dengan benar
        debugPrint('Response Data: $responseData');

        // Akses properti "data" di JSON
        if (responseData != null &&
            responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final menuData = responseData['data'];
          return Menu.fromJson(menuData);
        } else {
          throw Exception('Data tidak valid atau kosong.');
        }
      } else {
        throw Exception(
            'Gagal mengambil data menu. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  Future<bool> deleteMenu(String id) async {
    try {
      final url = '$_baseUrl/hapus/byid/$id';
      final response = await Dio().delete(
        url,
        options: Options(
          validateStatus: (status) {
            return status == 200 ||
                status == 403; // Terima 200 & 403 sebagai sukses
          },
        ),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 403) {
        return true;
      } else {
        throw Exception(
            'Gagal menghapus menu. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  Future<bool> updateMenuById(String id, Map<String, dynamic> menuData) async {
    try {
      // Susun URL dengan ID di path
      final url = '$_baseUrl/ubah/byid/$id';

      final response = await dio.put(
        url,
        data: menuData,
      );

      // Cek status code
      if (response.statusCode == 200 || response.statusCode == 403) {
        // Bersihkan respons dari pesan "Forbidden"
        String responseBody = response.data.toString();
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

        // Debug: Cetak respons untuk memastikan data diterima dengan benar
        debugPrint('Response Data: $responseData');

        // Cek apakah respons berhasil
        if (responseData != null && responseData is Map<String, dynamic>) {
          return true;
        } else {
          throw Exception('Gagal mengupdate menu. Data tidak valid.');
        }
      } else {
        throw Exception(
            'Gagal mengupdate menu. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  Future<bool> tambahPesanan(Pesanan pesanan) async {
    try {
      final String fullUrl = '$_baseUrl/tambah/pesanan';
      debugPrint('Request URL: $fullUrl');
      debugPrint('Request Data: ${pesanan.toJson()}');

      final response = await dio.post(
        fullUrl,
        data: pesanan.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Only content-type header
          },
          validateStatus: (status) {
            return status == 200 ||
                status == 403; // Accept 200 and 403 as success
          },
        ),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 403) {
        // Clean up the response if it starts with "Forbidden"
        String responseBody = response.data.toString();
        if (responseBody.startsWith('Forbidden')) {
          responseBody = responseBody.replaceFirst('Forbidden', '').trim();
        }

        // Parse the response body as JSON
        dynamic responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          throw Exception('Gagal mengurai JSON: $e');
        }

        debugPrint('Parsed Response Data: $responseData');

        // Check if the response data is valid
        if (responseData != null && responseData is Map<String, dynamic>) {
          // Check for success message
          if (responseData['message'] == 'Pesanan berhasil ditambahkan') {
            print('Pesanan berhasil ditambahkan!');
            return true;
          } else {
            throw Exception(
                'Gagal menambahkan pesanan: ${responseData['message']}');
          }
        } else {
          throw Exception('Gagal menambahkan pesanan. Data tidak valid.');
        }
      } else {
        throw Exception(
            'Gagal menambahkan pesanan. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException - Error: ${e.message}');
      displaySnackbar('Terjadi kesalahan saat menghubungi server.');
      return false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

 Future<void> updateStatusPesanan(String id, String newStatus) async {
  try {
    final String fullUrl = '$_baseUrl/update/status?id=$id';

    final response = await dio.patch(
      fullUrl,
      data: {
        'status_pesanan': newStatus, // Sesuaikan dengan key yang diharapkan backend
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json', // Tetap sertakan Content-Type
        },
      ),
    );

    // Handle respons null
    if (response.data == null) {
      print('Status pesanan berhasil diupdate (respons null).');
      return;
    }

    // Bersihkan respons dari pesan "Forbidden" jika ada
    String responseBody = response.data.toString(); // Pastikan responseBody adalah String
    if (responseBody.startsWith('Forbidden')) {
      responseBody = responseBody.replaceFirst('Forbidden', '').trim();
    }

    // Pastikan responseBody adalah JSON yang valid
    dynamic responseData;
    try {
      responseData = jsonDecode(responseBody);
    } catch (e) {
      // Jika parsing gagal, anggap sebagai update berhasil
      print('Status pesanan berhasil diupdate (respons tidak valid).');
      return;
    }

    // Cek status code
    if (response.statusCode == 200) {
      print('Status pesanan berhasil diupdate.');
      print('Response: $responseData');
    } else {
      throw Exception('Gagal mengupdate status pesanan. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Terjadi kesalahan saat mengupdate status pesanan: $e');
  }
}
}
