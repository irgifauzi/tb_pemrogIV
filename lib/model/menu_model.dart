// DIGUNAKAN UNTUK GET ALL DATA
class MenuModel {
  final String id;
  final String namaMenu;
  final double harga;
  final String deskripsi;
  final String gambar;
  final String kategori;

  MenuModel({
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategori,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        id: json["id"],
        namaMenu: json["nama_menu"],
        harga: (json["harga"] as num).toDouble(),
        deskripsi: json["deskripsi"],
        gambar: json["gambar"],
        kategori: json["kategori"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama_menu": namaMenu,
        "harga": harga,
        "deskripsi": deskripsi,
        "gambar": gambar,
        "kategori": kategori,
      };
}

// DIGUNAKAN UNTUK FORM INPUT
class MenuInput {
  final String namaMenu;
  final double harga;
  final String deskripsi;
  final String gambar;
  final String kategori;

  MenuInput({
    required this.namaMenu,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategori,
  });

  Map<String, dynamic> toJson() => {
        "nama_menu": namaMenu,
        "harga": harga,
        "deskripsi": deskripsi,
        "gambar": gambar,
        "kategori": kategori,
      };
}

// DIGUNAKAN UNTUK RESPONSE
class MenuResponse {
  final String? insertedId;
  final String message;
  final int status;

  MenuResponse({
    this.insertedId,
    required this.message,
    required this.status,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) => MenuResponse(
        insertedId: json["inserted_id"],
        message: json["message"],
        status: json["status"],
      );
}
