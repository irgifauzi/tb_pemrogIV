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

  Map<String, dynamic> toJson() {
    return {
      'nama_pelanggan': namaPelanggan,
      'nomor_meja': nomorMeja,
      'daftar_menu': daftarMenu.map((item) => {
        'menu_id': item['menu_id'], // Pastikan menu_id dikirim
        'nama_menu': item['nama_menu'],
        'jumlah': item['jumlah'],
        'harga_satuan': item['harga_satuan'], // Pastikan harga_satuan dikirim
        'subtotal': item['subtotal'], // Pastikan subtotal dikirim
      }).toList(),
      'total_harga': totalHarga,
      'catatan_pesanan': catatanPesanan,
    };
  }
}