import 'package:dio_contact/view/login_page.dart';
import 'package:dio_contact/view/screen/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:dio_contact/service/api_service.dart';
import 'package:dio_contact/model/menu_model.dart';
import 'package:intl/intl.dart'; // Import untuk NumberFormat

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
        _menuList = menuList ?? []; // Jika null, gunakan list kosong
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
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
                        child: SingleChildScrollView(
                          // Tambahkan SingleChildScrollView untuk scroll
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(), // Nonaktifkan scroll internal GridView
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  1, // Jumlah kolom diubah menjadi 1
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.5, // Atur proporsi card
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        child: menu.gambar.isNotEmpty
                                            ? Image.network(
                                                menu.gambar,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                      Icons.broken_image,
                                                      size: 50);
                                                },
                                              )
                                            : const Icon(Icons.fastfood,
                                                size: 50),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            menu.namaMenu,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            menu.deskripsi,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(menu.harga)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.teal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ButtonBar(
                                      alignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.shopping_cart,
                                              color: Colors.green),
                                          onPressed: () {
                                            // Tambahkan logika untuk pesan di sini
                                            print('Pesan ${menu.namaMenu}');
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
