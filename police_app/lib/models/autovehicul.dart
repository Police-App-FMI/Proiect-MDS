import 'package:police_app/models/individ.dart';

class Autovehicul {
  String nrInmatriculare;
  String model3D;
  DateTime dataAchizitie;
  double kilometraj;
  Individ? proprietar;

  Autovehicul({
    required this.nrInmatriculare,
    required this.model3D,
    required this.dataAchizitie,
    required this.kilometraj,
    this.proprietar,
  });

  factory Autovehicul.fromJson(Map<String, dynamic> json) {
    return Autovehicul(
      nrInmatriculare: json['nr_Inmatriculare'],
      model3D: json['model_3D'],
      dataAchizitie: DateTime.parse(json['data_Achizitie']),
      kilometraj: (json['kilometraj'] as num).toDouble(),
      proprietar: json['propietar'] != null ? Individ.fromJson(json['propietar']) : null,
    );
  }
}
