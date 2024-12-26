
class Supplier {
  final int id;
  final String nama;
  final String alamat;
  final String kontak;
  final String latitude;
  final String longitude;

  Supplier({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.kontak,
    required this.latitude,
    required this.longitude,
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] ?? 0,
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      kontak: map['kontak'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String,dynamic> {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'kontak': kontak,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      kontak: json['kontak'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }

}