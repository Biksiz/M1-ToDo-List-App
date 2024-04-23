import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_app/Models/tache.dart';

class TacheProvider extends ChangeNotifier {
  // Liste des tâches
  final List<Tache> _taches = [];

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

  // Retourne la liste des tâches actives
  List<Tache> get tachesActives => _taches.where(_isTacheActive).toList();

  // Retourne la liste des tâches terminées
  List<Tache> get tachesTerminees => _taches.where(_isTacheTerminee).toList();

  // Retourne la liste des tâches
  List<Tache> get taches => _taches;
}