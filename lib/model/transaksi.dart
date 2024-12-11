import 'dart:convert';

class TransaksiModel {
  final int? id;
  final int idProduct;
  final int jumlah;
  final String jenisTransaksi;
  final String tanggal;

  TransaksiModel(
      {this.id,
      required this.idProduct,
      required this.jumlah,
      required this.jenisTransaksi,
      required this.tanggal});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idProduct': idProduct,
      'jumlah': jumlah,
      'jenisTransaksi': jenisTransaksi,
      'tanggal': tanggal,
    };
  }

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as int?,
      idProduct: map['idProduct'] as int,
      jumlah: map['jumlah'] as int,
      jenisTransaksi: map['jenisTransaksi'] as String,
      tanggal: map['tanggal'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransaksiModel.fromJson(String source) =>
      TransaksiModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
