class Pesanan {
  final String namaPelanggan;
  final int nomorMeja;
  final List<Map<String, dynamic>> daftarMenu;
  final int totalHarga;
  final String catatanPesanan;

  Pesanan({
    required this.namaPelanggan,
    required this.nomorMeja,
    required this.daftarMenu,
    required this.totalHarga,
    required this.catatanPesanan,
  });

  // Convert Pesanan object to JSON
  Map<String, dynamic> toJson() {
    return {
      'nama_pelanggan': namaPelanggan,
      'nomor_meja': nomorMeja,
      'daftar_menu': daftarMenu,
      'total_harga': totalHarga,
      'catatan_pesanan': catatanPesanan,
    };
  }
}