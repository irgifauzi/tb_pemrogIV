import 'package:flutter/material.dart';
import 'package:dio_contact/service/api_service.dart';
import 'package:dio_contact/model/pesananbaru_model.dart';
import 'package:intl/intl.dart';

class pesanandiprosesPage extends StatefulWidget {
  const pesanandiprosesPage({super.key});

  @override
  State<pesanandiprosesPage> createState() => _pesanandiprosesPageState();
}

class _pesanandiprosesPageState extends State<pesanandiprosesPage> {
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
      final data = await _dataService.fetchDataPesanan('diproses');
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

  Future<void> _updateStatusPesanan(String id, String newStatus) async {
    try {
      await _dataService.updateStatusPesanan(id, newStatus);
      _fetchDataPesanan(); // Refresh data setelah update
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengupdate status: $e';
      });
    }
  }

  Future<void> _confirmUpdateStatus(String id, String newStatus) async {
    // Tampilkan dialog konfirmasi
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Update Status'),
          content:
              Text('Apakah Anda yakin ingin mengupdate status pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Batal
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Konfirmasi
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );

    // Jika pengguna mengonfirmasi, lakukan update status
    if (confirm == true) {
      try {
        await _dataService.updateStatusPesanan(id, newStatus);
        _fetchDataPesanan(); // Refresh data setelah update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status pesanan berhasil diupdate.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengupdate status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan Diproses'),
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
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _confirmUpdateStatus(
                                            pesanan.id, 'diproses');
                                      },
                                      icon: Icon(Icons.update, size: 16),
                                      label: Text('Diproses'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _confirmUpdateStatus(
                                            pesanan.id, 'selesai');
                                      },
                                      icon: Icon(Icons.check_circle, size: 16),
                                      label: Text('Selesai'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
