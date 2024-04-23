class Tache{
  
  String id;
  final String titre;
  final String dateModification;
  String? description;
  String? dateEcheance;
  String? adresse;
  bool importance;
  bool terminee;

  Tache({
    required this.id,
    required this.titre,
    required this.dateModification,
    this.description,
    this.dateEcheance,
    this.adresse,
    this.importance = false,
    this.terminee = false,
  });

  // Convertit une tâche en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'dateModification': dateModification,
      'description': description,
      'dateEcheance': dateEcheance,
      'adresse': adresse,
      'importance': importance ? true : false,
      'terminee': terminee ? true : false,
    };
  }

  @override
  String toString() {
    return 'Tache{id: $id, titre: $titre, dateModification: $dateModification, description: $description, dateEcheance: $dateEcheance, adresse: $adresse, importance: $importance, terminee: $terminee}';
  }

}