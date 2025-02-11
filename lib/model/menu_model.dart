class Menu {
  final String id; // Tetap ada, tapi tidak required
  final String namaMenu;
  final int harga;
  final String deskripsi;
  final String gambar;
  final String kategori;

  Menu({
    this.id = '', // Nilai default untuk id
    required this.namaMenu,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategori,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaMenu': namaMenu,
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'kategori': kategori,
    };
  }

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      namaMenu: json['nama_menu'],
      harga: json['harga'],
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      kategori: json['kategori'],
    );
  }
}