import 'package:dio_contact/service/auth_manager.dart';
import 'package:dio_contact/view/login_page.dart';
import 'package:dio_contact/view/screen/pesananbaru.dart';
import 'package:dio_contact/view/screen/pesanandiproses.dart';
import 'package:dio_contact/view/screen/pesananhistory.dart';
import 'package:dio_contact/view/screen/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:dio_contact/service/api_service.dart';
import 'package:dio_contact/model/menu_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final ApiServices _dataService = ApiServices();
  List<Menu> _menuList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  final _namamenuCtl = TextEditingController();
  final _hargaCtl = TextEditingController();
  final _deskripsiCtl = TextEditingController();
  final _gambarCtl = TextEditingController();
  final _kategoriCtl = TextEditingController();
  MenuResponse? ctRes;
  bool isEditing = false;
  String idMenu = '';

  late SharedPreferences logindata;
  String username = '';

  late SharedPreferences tokenData;
  String token = '';

  // Tambahkan variabel untuk menampilkan pesan sukses
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    inital();
    refreshMenuList();
  }

  void inital() async {
    logindata = await SharedPreferences.getInstance();
    tokenData = await SharedPreferences.getInstance();
    String? savedToken = tokenData.getString('token');

    setState(() {
      username = logindata.getString('username') ?? 'Guest';
      token = savedToken ?? 'Token tidak ditemukan';
    });
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

  Future<void> _postMenu() async {
    if (_formKey.currentState!.validate()) {
      final newMenu = MenuInput(
        namamenu: _namamenuCtl.text,
        harga: int.parse(_hargaCtl.text.replaceAll(RegExp(r'[^0-9]'), '')),
        deskripsi: _deskripsiCtl.text,
        gambar: _gambarCtl.text,
        kategori: _kategoriCtl.text,
      );

      try {
        final response = await _dataService.postMenu(newMenu);
        setState(() {
          ctRes = response;
          _successMessage = 'Menu berhasil ditambahkan!';
        });

        // Hilangkan pesan sukses setelah 3 detik
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _successMessage = null;
            });
          }
        });

        refreshMenuList();
        _namamenuCtl.clear();
        _hargaCtl.clear();
        _deskripsiCtl.clear();
        _gambarCtl.clear();
        _kategoriCtl.clear();
      } catch (e) {
        setState(() {
          _errorMessage = 'Gagal menambahkan menu: $e';
        });
      }
    }
  }

  Future<void> _updateMenu() async {
    if (_formKey.currentState!.validate()) {
      final updatedMenu = {
        "nama_menu": _namamenuCtl.text,
        "harga": int.parse(_hargaCtl.text.replaceAll(RegExp(r'[^0-9]'), '')),
        "deskripsi": _deskripsiCtl.text,
        "gambar": _gambarCtl.text,
        "kategori": _kategoriCtl.text,
      };

      try {
        bool isSuccess = await _dataService.updateMenuById(idMenu, updatedMenu);

        if (isSuccess) {
          setState(() {
            _successMessage = 'Menu berhasil diupdate!';
          });

          // Hilangkan pesan sukses setelah 3 detik
          Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _successMessage = null;
              });
            }
          });

          refreshMenuList();
          _namamenuCtl.clear();
          _hargaCtl.clear();
          _deskripsiCtl.clear();
          _gambarCtl.clear();
          _kategoriCtl.clear();
          setState(() {
            isEditing = false;
            idMenu = '';
          });
        } else {
          throw Exception('Update gagal, coba lagi.');
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Gagal mengupdate menu: $e';
        });
      }
    }
  }

  void _showDeleteConfirmationDialog(String id, String nama) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data $nama?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                bool success = await _dataService.deleteMenu(id);
                if (success) {
                  setState(() {
                    _successMessage = 'Menu berhasil dihapus!';
                  });

                  // Hilangkan pesan sukses setelah 3 detik
                  Timer(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _successMessage = null;
                      });
                    }
                  });

                  await refreshMenuList();
                } else {
                  debugPrint('Gagal menghapus menu');
                }
                Navigator.of(context).pop();
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('Dashboard Admin Restoran'),
        backgroundColor: Colors.brown[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              refreshMenuList();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'pesanan_baru') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pesananbaruPage()),
                );
              } else if (value == 'pesanan_diproses') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => pesanandiprosesPage()),
                );
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pesananhistoryPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'pesanan_baru',
                  child: Text('Pesanan Baru'),
                ),
                const PopupMenuItem<String>(
                  value: 'pesanan_diproses',
                  child: Text('Pesanan Diproses'),
                ),
                const PopupMenuItem<String>(
                  value: 'history',
                  child: Text('History'),
                ),
              ];
            },
          ),
          IconButton(
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card untuk menampilkan username dan token
            Card(
              color: Colors.brown[100],
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username: $username',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Token: ${token.length > 20 ? token.substring(0, 20) : token}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card untuk menampilkan pesan sukses
            if (_successMessage != null)
              Card(
                color: Colors.green[100],
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        _successMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Logo Ramen
            Image.asset(
              'assets/ramen.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),

            // Card untuk Form
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _namamenuCtl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Menu',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama menu tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _hargaCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga tidak boleh kosong';
                          }
                          if (int.tryParse(
                                  value.replaceAll(RegExp(r'[^0-9]'), '')) ==
                              null) {
                            return 'Harga harus berupa angka';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          String cleanedValue =
                              value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleanedValue.isNotEmpty) {
                            String formattedValue = NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(int.parse(cleanedValue));
                            _hargaCtl.value = TextEditingValue(
                              text: formattedValue,
                              selection: TextSelection.collapsed(
                                  offset: formattedValue.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _deskripsiCtl,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _gambarCtl,
                        decoration: const InputDecoration(
                          labelText: 'URL Gambar',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'URL gambar tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: (_kategoriCtl.text.isNotEmpty &&
                                (_kategoriCtl.text == 'Makanan' ||
                                    _kategoriCtl.text == 'Minuman'))
                            ? _kategoriCtl.text
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Makanan', child: Text('Makanan')),
                          DropdownMenuItem(
                              value: 'Minuman', child: Text('Minuman')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _kategoriCtl.text = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kategori tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: isEditing ? _updateMenu : _postMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[800],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: Text(
                          isEditing ? 'Update Menu' : 'Tambah Menu',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (isEditing)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            _namamenuCtl.clear();
                            _hargaCtl.clear();
                            _deskripsiCtl.clear();
                            _gambarCtl.clear();
                            _kategoriCtl.clear();
                            setState(() {
                              isEditing = false;
                              idMenu = '';
                            });
                          },
                          child: const Text('Batal Update',
                              style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Daftar Menu
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
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
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: menu.gambar.isNotEmpty
                                        ? Image.network(
                                            menu.gambar,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                  Icons.broken_image,
                                                  size: 50);
                                            },
                                          )
                                        : const Icon(Icons.fastfood, size: 50),
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
                                  alignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        final menu = await _dataService
                                            .getMenuById(_menuList[index].id);
                                        setState(() {
                                          if (menu != null) {
                                            _namamenuCtl.text = menu.namaMenu;
                                            _hargaCtl.text =
                                                NumberFormat.currency(
                                              locale: 'id_ID',
                                              symbol: 'Rp ',
                                              decimalDigits: 0,
                                            ).format(menu.harga);
                                            _deskripsiCtl.text = menu.deskripsi;
                                            _gambarCtl.text = menu.gambar;
                                            _kategoriCtl.text = menu.kategori;
                                            isEditing = true;
                                            idMenu = menu.id;
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(
                                            _menuList[index].id,
                                            _menuList[index].namaMenu);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Anda yakin ingin logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              await AuthManager.logout();
              Navigator.pushAndRemoveUntil(
                dialogContext,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Ya'),
          ),
        ],
      );
    },
  );
}
