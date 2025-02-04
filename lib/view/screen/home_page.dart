import 'package:flutter/material.dart';
import 'package:dio_contact/model/menu_model.dart';
import 'package:dio_contact/service/api_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiServices _dataService = ApiServices();
  List<Menu> _menuMdl = [];
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
        if (menuList != null) {
          _menuMdl = menuList;
        } else {
          _errorMessage = 'Gagal memuat data menu. Silakan coba lagi.';
        }
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
      appBar: AppBar(title: const Text('Menu List')),
      body: RefreshIndicator(
        onRefresh: refreshMenuList,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : ListView.separated(
                    itemBuilder: (context, index) {
                      final menu = _menuMdl[index];
                      return Card(
                        child: ListTile(
                          leading: menu.gambar.isNotEmpty
                              ? Image.network(
                                  menu.gambar,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image);
                                  },
                                )
                              : const Icon(Icons.fastfood),
                          title: Text(menu.namaMenu),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(menu.deskripsi),
                              const SizedBox(height: 4),
                              Text(
                                'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(menu.harga)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: _menuMdl.length,
                  ),
      ),
    );
  }
}
