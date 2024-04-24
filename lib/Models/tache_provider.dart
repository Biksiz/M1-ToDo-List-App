import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_app/Models/tache.dart';

class TacheProvider extends ChangeNotifier {
  // Liste des tâches
  List<Tache> _taches = [];

  // Base de données
  Database? _db;

  // Initialise la base de données
  Future initDB() async {
    if (_db != null) {
      return _db;
    }
    try {
      String path = join(await getDatabasesPath(), 'taches.db');
      _db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE taches(
            id TEXT PRIMARY KEY,
            titre TEXT,
            dateModification TEXT,
            description TEXT,
            dateEcheance TEXT,
            adresse TEXT,
            importance BOOLEAN DEFAULT FALSE,
            terminee BOOLEAN DEFAULT FALSE
          )
        ''');
      });
    } 
    catch (e) {
      // TODO: code à enlever
      print(e);
    }
    return _db;
  }

  // Ajoute une tâche
  Future<void> addTache(Tache tache) async {
    // Initialise la base de données
    await initDB();

    // Ajoute la tâche à la liste
    _taches.add(tache);

    // Ajoute la tâche à la base de données et si elle existe déjà, la remplace
    await _db?.insert('taches', tache.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // Notifie les observateurs
    notifyListeners();
  }

  // Supprime une tâche
  Future<void> removeTache(Tache tache) async {
    await initDB();
    _taches.remove(tache);

    // Supprime la tâche de la base de données et si elle n'existe pas, ne fait rien
    await _db?.delete('taches', where: 'id = ?', whereArgs: [tache.id]);
    notifyListeners();
  }

  // Met à jour une tâche
  Future<void> updateTache(Tache tache) async {
    await initDB();

    // Met à jour la tâche dans la liste _taches
    int index = _taches.indexWhere((t) => t.id == tache.id);

    // Verifie si la tâche existe
    if (index != -1) {
      _taches[index] = tache;
      
      // Met à jour la tâche dans la base de données et si elle n'existe pas, ne fait rien
      await _db?.update('taches', tache.toMap(), where: 'id = ?', whereArgs: [tache.id]);
      notifyListeners();
    }
  }

  // Change le statut d'importance d'une tâche
  Future<void> updateImportance(String id, bool importance) async {
    await initDB();

    // Met à jour la tâche dans la liste _taches
    int index = _taches.indexWhere((t) => t.id == id);

    // Verifie si la tâche existe
    if (index != -1) {
      _taches[index].importance = importance;

      // Met à jour la tâche dans la base de données et si elle n'existe pas, ne fait rien
      await _db?.update('taches', {'importance': importance}, where: 'id = ?', whereArgs: [id]);
      notifyListeners();
    }
  }

  // Change le statut de terminée d'une tâche
  Future<void> updateTerminee(String id, bool terminee) async {
    await initDB();

    // Met à jour la tâche dans la liste _taches
    int index = _taches.indexWhere((t) => t.id == id);

    // Verifie si la tâche existe
    if (index != -1) {
      _taches[index].terminee = terminee;

      // Met à jour la tâche dans la base de données et si elle n'existe pas, ne fait rien
      await _db?.update('taches', {'terminee': terminee}, where: 'id = ?', whereArgs: [id]);
      notifyListeners();
    }
  }

  // Verifie si une tâche est active
  bool _isTacheActive(Tache tache) {
    return !tache.terminee;
  }

  // Verifie si une tâche est terminée
  bool _isTacheTerminee(Tache tache) {
    return tache.terminee;
  }

  // Retourne la liste des tâches actives triée selon la méthode de tri spécifiée
  Future<List<Tache>> getTachesActives(Function(List<Tache>) methodeTrie) async {
    return methodeTrie((await getTaches()).where(_isTacheActive).toList());
  }

  // Retourne la liste des tâches terminées triée selon la méthode de tri spécifiée
  Future<List<Tache>> getTachesTerminees(Function(List<Tache>) methodeTrie) async {
    return methodeTrie((await getTaches()).where(_isTacheTerminee).toList());
  }

  // Charge les tâches depuis la base de données
  Future<List<Tache>> getTaches() async {

    if (_taches.isNotEmpty) {
      return _taches;
    }

    await initDB();

    // Charge les tâches depuis la base de données
    List<Map<String, dynamic>> taches = await _db!.query('taches');

    // Convertit les tâches en objets Tache
    _taches = [
      for (final {'id' : id as String, 'titre' : titre as String, 'dateModification' : dateModification as String, 'description' : description as String?, 'dateEcheance' : dateEcheance as String?, 'adresse' : adresse as String?, 'importance' : importance as int, 'terminee' : terminee as int} in taches)
        Tache(
          id: id,
          titre: titre,
          dateModification: dateModification,
          description: description,
          dateEcheance: dateEcheance,
          adresse: adresse,
          importance: importance == 1,
          terminee: terminee == 1
        ),
    ];

    return _taches;
  }

  // Trie par importance puis par date de modification
  List<Tache> triParDefaut(List<Tache> taches) {
    taches.sort((a, b) {

      // Si les deux tâches ont la même importance, on les trie par date de modification
      if (a.importance == b.importance) {
        return DateTime.parse(b.dateModification).compareTo(DateTime.parse(a.dateModification));
      } 

      // Sinon, on trie par importance
      else {
        return a.importance ? -1 : 1;
      }
    });

    return taches;
  }

  // Trie par date d'échéance puis par date de modification en cas d'égalité
  List<Tache> triParDateEcheance(List<Tache> taches) {
    taches.sort((a, b) {

      // Si les deux tâches ont une date d'échéance, on les trie par date d'échéance
      if (a.dateEcheance != null && b.dateEcheance != null) {

        // Nos dates convertient en DateTime
        var dateA = DateTime.parse(a.dateEcheance!);
        var dateB = DateTime.parse(b.dateEcheance!);

        // Si les deux dates d'échéance sont égales, on les trie par date de modification
        if (dateA == dateB) {
          return DateTime.parse(b.dateModification).compareTo(DateTime.parse(a.dateModification));
        } 
        else {
          return dateB.compareTo(dateA);
        }
      } 

      // Si une des tâches n'a pas de date d'échéance, on la met en dernier
      else if (a.dateEcheance == null && b.dateEcheance == null) {
        return DateTime.parse(b.dateModification).compareTo(DateTime.parse(a.dateModification));
      }

      // Si la tâche A n'a pas de date d'échéance, on la met en dernier
      else {
        return a.dateEcheance == null ? 1 : -1;
      }
    });

    return taches;
  }
}