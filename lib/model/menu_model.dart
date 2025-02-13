class Menu {
  final String id;
 final String namaMenu;
  final int harga; // Ubah dari String ke int
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

//DIGUNAKAN UNTUK FORM INPUT
class MenuInput {
  final String namamenu;
  final int harga;
  final String deskripsi;
  final String gambar;
  final String kategori;

  MenuInput({
    required this.namamenu,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategori,
  });

  Map<String, dynamic> toJson() => {
        "nama_menu": namamenu,
        "harga": harga,
        "deskripsi": deskripsi,
        "gambar": gambar,
        "kategori": kategori,
      };
}

//DIGUNAKAN UNTUK RESPONSE
class MenuResponse {
  final String? insertedId;
  final String message;

  MenuResponse({
    this.insertedId,
    required this.message,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) => MenuResponse(
        insertedId: json["inserted_id"],
        message: json["message"],
      );
}
