class Menu {
  final String id;
  final String namaMenu;
  final int harga;
  final String deskripsi;
  final String gambar;
  final String kategori;

  Menu({
    this.id = '', // Default kosong untuk id
    required this.namaMenu,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategori,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_menu': namaMenu, // Pastikan snake_case jika mengikuti API
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'kategori': kategori,
    };
  }

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] ?? '', // Pastikan tidak null
      namaMenu: json['nama_menu'] ?? '',
      harga: json['harga'] ?? 0,
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'] ?? '',
      kategori: json['kategori'] ?? '',
    );
  }
}
