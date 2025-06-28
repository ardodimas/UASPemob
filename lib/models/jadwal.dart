class Jadwal {
  final int? id;
  final String hari;
  final String mapel;
  final String jamMulai;
  final String jamSelesai;
  final String catatan;
  final String? imagePath;

  Jadwal({
    this.id,
    required this.hari,
    required this.mapel,
    required this.jamMulai,
    required this.jamSelesai,
    required this.catatan,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hari': hari,
      'mapel': mapel,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'catatan': catatan,
      'imagePath': imagePath,
    };
  }

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'],
      hari: map['hari'] ?? '',
      mapel: map['mapel'],
      jamMulai: map['jamMulai'],
      jamSelesai: map['jamSelesai'],
      catatan: map['catatan'],
      imagePath: map['imagePath'],
    );
  }
}
