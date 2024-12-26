
class Transaksi {
  final int? id;
  final int idProduct;
  final int jumlah;
  final String jenisTransaksi;
  final DateTime tanggal;

  Transaksi(
      {this.id,
      required this.idProduct,
      required this.jumlah,
      required this.jenisTransaksi,
      required this.tanggal});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idProduct': idProduct,
      'jumlah': jumlah,
      'jenisTransaksi': jenisTransaksi,
      'tanggal': tanggal,
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'] as int?,
      idProduct: map['idProduct'] as int,
      jumlah: map['jumlah'] as int,
      jenisTransaksi: map['jenisTransaksi'] as String,
      tanggal: map['tanggal'] as DateTime,
    );
  }

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      idProduct: json['idProduct'],
      tanggal: DateTime.parse(json['tanggal']),
      jumlah: json['jumlah'],
      jenisTransaksi: json['jenisTransaksi'],
    );
  }

}
