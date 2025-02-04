class Menu {
  final String id;
  final String namaMenu;
  final int harga;
  final String deskripsi;
  final String gambar;
  final String kategori;

  Menu({
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategori,
  });

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
