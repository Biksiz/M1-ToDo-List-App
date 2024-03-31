class TacheModel{
  final String id;
  final String titre;
  final String description;
  final String date;
  final String adresse;
  final String importance;
  final bool etat;

  const TacheModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.date,
    required this.adresse,
    required this.importance,
    required this.etat
  });

}