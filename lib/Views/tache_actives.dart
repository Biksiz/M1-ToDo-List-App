import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list_app/Models/tache.dart';
import 'package:todo_list_app/Models/tache_provider.dart';
import 'package:provider/provider.dart';

class TacheActivesScreen extends StatefulWidget {
  const TacheActivesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TacheActivesScreenState createState() => _TacheActivesScreenState();
}

class _TacheActivesScreenState extends State<TacheActivesScreen> {
  // Valeur actuelle du dropdown de tri
  String? dropdownValue = 'Trier: Alphabetique';

  // Controller pour le champ de texte de la tâche
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar( // Barre du haut de l'app
        title: Text('Tâches actives', style: GoogleFonts.racingSansOne(color: Colors.purple) ),
        actions: [

          // DropdownButton pour trier les tâches
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              // Valeur par défaut
              value: dropdownValue,

              // Icone du bouton
              icon: const Icon(CupertinoIcons.sort_down),

              // Lorsque la valeur est changée
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },

              // Liste des items
              items: <String>['Trier: Alphabetique', 'Trier: Date d\'échéance', 'Trier: Importance']
                .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>( // Item du dropdown
                    value: value,
                    child: Text(value, style: GoogleFonts.roboto(color: Colors.purple)),
                  );
                }).toList(),
            ),
          ),
          
        ],
      ),

      body: Consumer<TacheProvider>( // Ecoute les changements dans TacheProvider
        builder: (context, tacheProvider, child) {

          // Si la liste des tâches actives est vide
          if (tacheProvider.tachesActives.isEmpty) {
            return Center(
              child: Text('Aucune tâche active', style: GoogleFonts.roboto(color: Colors.purple, fontSize: 24.0, fontWeight: FontWeight.bold)),
            );
          }

          // Liste des tâches actives
          return ListView.builder(
            itemCount: tacheProvider.tachesActives.length,
            itemBuilder: (context, index) {

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Dismissible(
                  key: Key(tacheProvider.tachesActives[index].id),

                  // Fond lorsqu'on swipe à droite
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),

                  // Fond lorsqu'on swipe à gauche
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),

                  onDismissed: (direction) {
                    // Supprime la tâche lorsqu'il y a un swipe
                    tacheProvider.removeTache(tacheProvider.tachesActives[index]);

                    // Affiche un SnackBar pour confirmer la suppression
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Tâche supprimée avec succès',
                          style: GoogleFonts.roboto(color: Colors.white),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },

                  child: Card(
                    color: Colors.purpleAccent.withOpacity(0.2),

                    child: ListTile(
                      title: Text(
                        tacheProvider.tachesActives[index].titre.length > 40 // Si le titre est plus long que 40 caractères alors afficher ...
                          ? '${tacheProvider.tachesActives[index].titre.substring(0, 40)}...'
                          : tacheProvider.tachesActives[index].titre, 
                        style: GoogleFonts.acme(fontWeight: FontWeight.bold),
                      ),

                      // Date d'écheance affichée si elle existe sinon affiche "Pas de date"
                      subtitle: Text("Date d'échéance: ${tacheProvider.tachesActives[index].dateEcheance ?? 'Pas de date'}", style: GoogleFonts.acme()),

                      trailing: IconButton(
                        icon: Icon(
                          tacheProvider.tachesActives[index].importance 
                            ? CupertinoIcons.bookmark_fill 
                            : CupertinoIcons.bookmark,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // Change le statut d'importance de la tâche
                          tacheProvider.updateImportance(tacheProvider.tachesActives[index].id, !tacheProvider.tachesActives[index].importance);

                          // Affiche un SnackBar pour confirmer le changement de statut d'importance
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.purple,
                              content: Text('"${tacheProvider.tachesActives[index].titre}" est ${tacheProvider.tachesActives[index].importance ? 'non importante' : 'importante'}',
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                        },
                      ),
                    ),
                  ),

                ),
              );

            },
          );

        },
      ),

      floatingActionButton: FloatingActionButton( // Bouton floatant pour ajouter une tâche
        onPressed: () {
          // BottomSheet pour ajouter une tâche
          showBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),

      
    );
  }

  // Affiche un BottomSheet pour ajouter une tâche
  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {

        return Container(
          height: MediaQuery.of(context).size.height / 2, // Hauteur de l'écran / 2
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[

              // Titre du BottomSheet
              Text('Ajouter une tâche', style: GoogleFonts.racingSansOne(fontSize: 24.0, color: Colors.purple)),

              // Champ de texte pour le titre de la tâche
              TextField(
                controller: _taskController, // Controller pour le champ de texte
                decoration: const InputDecoration( // Placeholder du champ de texte
                  hintText: 'Entrez votre tâche',
                ),
              ),

              // Boutons pour annuler ou créer la tâche
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {
                      // Fermer le BottomSheet
                      Navigator.pop(context);
                    },
                    child: const Text('Annuler'),
                  ),

                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {

                      // Créer une tâche
                      Tache tache = Tache(
                        titre: _taskController.text,
                        dateModification: DateTime.now().toString(),
                      );

                      // Vérifie si le champ de texte n'est pas vide
                      if (_taskController.text.isNotEmpty){

                        // Ajoute la tâche à la liste
                        Provider.of<TacheProvider>(context, listen: false).addTache(tache);
                      }

                      else {
                        // Affiche un SnackBar si le champ de texte est vide
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Veuillez entrer un nom de tâche valide',
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }

                      // Ferme le BottomSheet
                      Navigator.pop(context);

                    },
                    child: const Text('Créer'),
                  ),
                ],
              ),

            ],
          ),
        );

      },
    );
  }

  // Dispose du controller pour éviter les fuites de mémoire
  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

}