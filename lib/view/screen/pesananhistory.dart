import 'package:flutter/material.dart';
import 'package:dio_contact/service/api_service.dart';
import 'package:dio_contact/model/pesananbaru_model.dart';
import 'package:intl/intl.dart';

class pesananhistoryPage extends StatefulWidget {
  const pesananhistoryPage({super.key});

  @override
  State<pesananhistoryPage> createState() => _pesananhistoryPageState();
}

class _pesananhistoryPageState extends State<pesananhistoryPage> {
  final ApiServices _dataService = ApiServices();
  List<PesananbaruModel> _pesananList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDataPesanan();
  }

  Future<void> _fetchDataPesanan() async {
    try {
      final data = await _dataService.fetchDataPesanan('selesai');
      setState(() {
        _pesananList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengambil data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Pesanan'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _pesananList.isEmpty
                  ? Center(child: Text('Tidak ada data pesanan.'))
                  : ListView.builder(
                      itemCount: _pesananList.length,
                      itemBuilder: (context, index) {
                        final pesanan = _pesananList[index];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nama Pelanggan: ${pesanan.namaPelanggan}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('Nomor Meja: ${pesanan.nomorMeja}'),
                                SizedBox(height: 8),
                                Text(
                                  'Daftar Menu:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...pesanan.daftarMenu.map((menu) {
                                  return Text(
                                    '- ${menu['nama_menu']} (${menu['jumlah']} x Rp${menu['harga_satuan'] ?? menu['subtotal'] ?? 0})',
                                  );
                                }).toList(),
                                SizedBox(height: 8),
                                Text('Total Harga: Rp${pesanan.totalHarga}'),
                                SizedBox(height: 8),
                                Text('Catatan: ${pesanan.catatanPesanan}'),
                                SizedBox(height: 8),
                                Text(
                                  'Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(pesanan.tanggalPesanan)}',
                                ),
                                SizedBox(height: 8),
                                Text('Pembayaran: ${pesanan.pembayaran}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
