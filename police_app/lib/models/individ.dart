import 'package:police_app/models/autovehicul.dart';

class Individ {
  int? $id;
  String cnp;
  String nume;
  String permis_Validare;
  DateTime data_Nastere;
  String adresa_Domiciliu;
  List<Autovehicul>? masinile;
  String? id;
  DateTime? dateCreated;
  DateTime? dateModified;
  bool? isDeleted;

  Individ({
    required this.cnp,
    required this.nume,
    required this.permis_Validare,
    required this.data_Nastere,
    required this.adresa_Domiciliu,
    this.masinile
  });

  factory Individ.fromJson(Map<String, dynamic> json) {
    return Individ(
      cnp: json['cnp'],
      nume: json['nume'],
      permis_Validare: json['permis_Validare'],
      data_Nastere: DateTime.parse(json['data_Nastere']),
      adresa_Domiciliu: json['adresa_Domiciliu'],
      masinile: json['masinile'] != null && json['masinile']['\$values'] != null
          ? List<Autovehicul>.from(
              json['masinile']['\$values'].map((x) => Autovehicul.fromJson(x)))
          : null,
    );
  }
}
