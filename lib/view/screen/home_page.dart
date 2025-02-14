import 'package:dio_contact/service/auth_manager.dart';
import 'package:dio_contact/view/login_page.dart';
import 'package:dio_contact/view/screen/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:dio_contact/service/api_service.dart';
import 'package:dio_contact/model/menu_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio_contact/view/screen/widget/menu_card.dart';

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

  Future<void> _postMenu() async {
    if (_formKey.currentState!.validate()) {
      final newMenu = MenuInput(
        namamenu: _namamenuCtl.text,
        harga: int.parse(_hargaCtl.text
            .replaceAll(RegExp(r'[^0-9]'), '')), // Perbaikan di sini
        deskripsi: _deskripsiCtl.text,
        gambar: _gambarCtl.text,
        kategori: _kategoriCtl.text,
      );

      try {
        final response = await _dataService.postMenu(newMenu);
        setState(() {
          ctRes = response;
        });
        refreshMenuList();
        _namamenuCtl.clear();
        _hargaCtl.clear();
        _deskripsiCtl.clear();
        _gambarCtl.clear();
        _kategoriCtl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu berhasil ditambahkan!')),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Gagal menambahkan menu: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan menu: $e')),
        );
      }
    }
  }

  Future<void> _updateMenu() async {
    if (_formKey.currentState!.validate()) {
      final updatedMenu = {
        "nama_menu": _namamenuCtl.text,
        "harga": int.parse(_hargaCtl.text
            .replaceAll(RegExp(r'[^0-9]'), '')), // Perbaikan di sini
        "deskripsi": _deskripsiCtl.text,
        "gambar": _gambarCtl.text,
        "kategori": _kategoriCtl.text,
      };

      try {
        bool isSuccess = await _dataService.updateMenuById(idMenu, updatedMenu);

        if (isSuccess) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil diupdate!')),
          );
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

  Widget hasilCard(BuildContext context) {
    return Column(
      children: [
        if (ctRes != null)
          MenuCard(
            ctRes: ctRes!,
          )
        else
          const SizedBox.shrink(), // Jika ctRes null, tampilkan widget kosong
      ],
    );
  }

  void _showDeleteConfirmationDialog(String id, String nama) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data $nama ?'),
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
      appBar: AppBar(
        title: const Text('Dashboard Admin Restoran'),
        actions: [
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 2.0),
                color: Colors.tealAccent,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle_rounded),
                          const SizedBox(width: 8.0),
                          Text(
                            'Login sebagai: $username',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          const Icon(Icons.key_rounded),
                          const SizedBox(width: 8.0),
                          Text(
                            'Token: ${token.length > 20 ? token.substring(0, 20) + '...' : token}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              TextFormField(
                controller: _namamenuCtl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nama Menu',
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
                  border: OutlineInputBorder(),
                  labelText: 'Harga',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ==
                      null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Format harga ke dalam bentuk Rupiah
                  String cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
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
                  border: OutlineInputBorder(),
                  labelText: 'Deskripsi',
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
                  border: OutlineInputBorder(),
                  labelText: 'URL Gambar',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL gambar tidak boleh kosong';
                  }
                  return null;
                },
                readOnly: false, // Pastikan ini diatur ke false agar bisa paste
                enableInteractiveSelection:
                    true, // Agar bisa pilih teks dan paste
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: (_kategoriCtl.text.isNotEmpty &&
                        (_kategoriCtl.text == 'Makanan' ||
                            _kategoriCtl.text == 'Minuman'))
                    ? _kategoriCtl.text
                    : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Kategori',
                ),
                items: const [
                  DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                  DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
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
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: isEditing ? _updateMenu : _postMenu,
                      child:
                          Text(isEditing ? 'Update Menu' : 'Post Menu Makanan'),
                    ),
                    if (isEditing) // Tampilkan tombol "Cancel Update" hanya jika sedang dalam mode edit
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          // Reset form dan keluar dari mode edit
                          _namamenuCtl.clear();
                          _hargaCtl.clear();
                          _deskripsiCtl.clear();
                          _gambarCtl.clear();
                          _kategoriCtl.clear();
                          setState(() {
                            isEditing = false; // Keluar dari mode edit
                            idMenu = ''; // Reset ID menu
                          });
                        },
                        child: const Text('Cancel Update'),
                      ),
                    // Tambahkan hasilCard di sini
                    hasilCard(context),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Jumlah kolom, bisa disesuaikan
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8, // Atur proporsi card
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
                                              _hargaCtl
                                                  .text = NumberFormat.currency(
                                                locale: 'id_ID',
                                                symbol: 'Rp ',
                                                decimalDigits: 0,
                                              ).format(menu
                                                  .harga); // Perbaikan format Rupiah
                                              _deskripsiCtl.text =
                                                  menu.deskripsi;
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
                // ignore: use_build_context_synchronously
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
