class PesananbaruModel {
  final String id;
  final String namaPelanggan;
  final int nomorMeja;
  final List<Map<String, dynamic>> daftarMenu;
  final int totalHarga;
  final String catatanPesanan;
  final String statusPesanan; // Sesuaikan dengan key di JSON
  final DateTime tanggalPesanan; // Sesuaikan dengan key di JSON
  final String pembayaran;

  PesananbaruModel({
    required this.id,
    required this.namaPelanggan,
    required this.nomorMeja,
    required this.daftarMenu,
    required this.totalHarga,
    required this.catatanPesanan,
    required this.statusPesanan,
    required this.tanggalPesanan,
    required this.pembayaran,
  });

  // Metode toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_pelanggan': namaPelanggan,
      'nomor_meja': nomorMeja,
      'daftar_menu': daftarMenu,
      'total_harga': totalHarga,
      'catatan_pesanan': catatanPesanan,
      'status_pesanan': statusPesanan,
      'tanggal_pesanan': tanggalPesanan.toIso8601String(),
      'pembayaran': pembayaran,
    };
  }

  // Metode fromJson
  factory PesananbaruModel.fromJson(Map<String, dynamic> json) {
    return PesananbaruModel(
      id: json['id'] as String? ?? '',
      namaPelanggan: json['nama_pelanggan'] as String? ?? '',
      nomorMeja: json['nomor_meja'] as int? ?? 0,
      daftarMenu: (json['daftar_menu'] as List<dynamic>?)?.map((menu) {
            return {
              'menu_id': menu['menu_id'] as String? ?? '',
              'nama_menu': menu['nama_menu'] as String? ?? '',
              'jumlah': menu['jumlah'] as int? ?? 0,
              'harga_satuan': menu['harga_satuan'] as int? ?? 0,
              'subtotal': menu['subtotal'] as int? ?? 0,
            };
          }).toList() ??
          [], // Jika daftar_menu null, gunakan list kosong
      totalHarga: json['total_harga'] as int? ?? 0,
      catatanPesanan: json['catatan_pesanan'] as String? ?? '',
      statusPesanan: json['status_pesanan'] as String? ?? '',
      tanggalPesanan: DateTime.parse(json['tanggal_pesanan'] as String? ??
          DateTime.now().toIso8601String()),
      pembayaran: json['pembayaran'] as String? ?? '',
    );
  }
}
