class Mapel {
  final int? id;
  final String nama;

  Mapel({this.id, required this.nama});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nama': nama};
  }

  factory Mapel.fromMap(Map<String, dynamic> map) {
    return Mapel(id: map['id'], nama: map['nama'] ?? '');
  }
}
