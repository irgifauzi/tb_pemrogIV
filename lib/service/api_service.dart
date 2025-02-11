import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio_contact/model/menu_model.dart';

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

  // Fungsi untuk POST data menu baru
  Future<Response?> postMenu(Menu menu) async {
    try {
      final String fullUrl = '$_baseUrl/tambah/menu_ramen';
      final response = await dio.post(
        fullUrl,
        data: menu.toJson(), // Mengubah objek Menu menjadi JSON
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Set header untuk JSON
          },
        ),
      );

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

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 403) {
        print('Menu berhasil ditambahkan: $responseData');
        return Response.fromJson(
            responseData); // Mengembalikan objek MenuResponse
      } else {
        throw Exception(
            'Gagal menambahkan menu. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat menambahkan menu');
    }
  }
}
