import 'package:dio_contact/model/pesanan_model.dart';
import 'package:flutter/material.dart';
import 'package:dio_contact/service/api_service.dart';
import 'package:dio_contact/model/menu_model.dart';
import 'package:intl/intl.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  final ApiServices _dataService = ApiServices();
  List<Menu> _menuList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedSeat = 1;
  final TextEditingController _namaPelangganController =
      TextEditingController();
  final TextEditingController _catatanPesananController =
      TextEditingController();
  double _totalHarga = 0.0;
  Map<Menu, int> _cart = {}; // Menyimpan item dan jumlah dalam keranjang

  @override
  void initState() {
    super.initState();
    refreshMenuList();
  }

  Future<void> refreshMenuList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final menuList = await _dataService.fetchMenuItems();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _menuList = menuList ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  void _updateTotalHarga() {
    _totalHarga = _cart.entries.fold(0.0, (total, entry) {
      return total + (entry.key.harga * entry.value);
    });
  }

  void _showCartDialog() {
    _updateTotalHarga();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Keranjang'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: _cart.entries.map((entry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${entry.key.namaMenu} (x${entry.value})',
                                overflow: TextOverflow
                                    .ellipsis, // Tambahkan ini agar teks panjang dipotong
                              ),
                            ),
                            Text(NumberFormat.currency(
                                    locale: 'id_ID', symbol: 'Rp')
                                .format(entry.key.harga * entry.value)),
                            Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Tambahkan ini agar tidak melebar ke kanan
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      if (_cart[entry.key]! > 1) {
                                        _cart[entry.key] =
                                            _cart[entry.key]! - 1;
                                      } else {
                                        _cart.remove(entry.key);
                                      }
                                      _updateTotalHarga();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.add, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      _cart[entry.key] = _cart[entry.key]! + 1;
                                      _updateTotalHarga();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _cart.remove(entry.key);
                                      _updateTotalHarga();
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        );
                      }).toList(),
                    ),
                    const Divider(),
                    TextField(
                      controller: _namaPelangganController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pelanggan',
                      ),
                    ),
                    TextField(
                      controller: _catatanPesananController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Pesanan (optional)',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButton<int>(
                      value: _selectedSeat,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedSeat = newValue!;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(
                        10,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('Kursi ${index + 1}'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(_totalHarga)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Add More Menu'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Konfirmasi Pesanan'),
                  onPressed: () async {
  final namaPelanggan = _namaPelangganController.text;
  final catatanPesanan = _catatanPesananController.text;

  if (namaPelanggan.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nama pelanggan harus diisi')),
    );
    return;
  }

  // Ubah data dari _cart menjadi daftar menu untuk model Pesanan
  List<Map<String, dynamic>> daftarMenu = _cart.entries.map((entry) {
    return {
      'nama_menu': entry.key.namaMenu,
      'jumlah': entry.value,
      'harga': entry.key.harga,
    };
  }).toList();

  // Buat objek Pesanan
  final pesanan = Pesanan(
    namaPelanggan: namaPelanggan,
    nomorMeja: _selectedSeat,
    daftarMenu: daftarMenu,
    totalHarga: _totalHarga.toInt(),
    catatanPesanan: catatanPesanan,
  
  );

  try {
    // Panggil fungsi tambahPesanan dari ApiServices
    await _dataService.tambahPesanan(pesanan);

    // Berhasil ditambahkan, tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan berhasil ditambahkan')),
    );

    // Kosongkan keranjang dan field input
    setState(() {
      _cart.clear();
      _totalHarga = 0.0;
      _namaPelangganController.clear();
      _catatanPesananController.clear();
    });

    Navigator.of(context).pop();
  } catch (e) {
    // Tampilkan pesan error jika gagal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menambahkan pesanan: $e')),
    );
  }
},

                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _cart.isNotEmpty ? _showCartDialog : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _menuList.length,
                          itemBuilder: (context, index) {
                            final menu = _menuList[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      menu.gambar,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(menu.namaMenu,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(menu.harga)}'),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    child: const Text('Tambah ke Keranjang'),
                                    onPressed: () {
                                      setState(() {
                                        _cart.update(menu, (value) => value + 1,
                                            ifAbsent: () => 1);
                                        _updateTotalHarga();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
