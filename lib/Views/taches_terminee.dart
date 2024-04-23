import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/Models/tache_provider.dart';

class TacheTermineeScreen extends StatefulWidget {
  const TacheTermineeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TacheTermineeScreenState createState() => _TacheTermineeScreenState();
}

class _TacheTermineeScreenState extends State<TacheTermineeScreen> {
  String? dropdownValue = 'Trier: Alphabetique';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar( // Barre du haut de l'app
        title: Text('Tâches terminées', style: GoogleFonts.racingSansOne(color: Colors.purple) ),
        actions: [
         
          // DropdownButton pour trier les tâches
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                    child: Text(value, style: GoogleFonts.oswald(color: Colors.purple)),
                  );
                }).toList(),
            ),
          ),

        ],
      ),

      body: Consumer<TacheProvider>( // Ecoute les changements dans TacheProvider
        builder: (context, tacheProvider, child) {

          // Si aucune tâche n'est terminée
          if (tacheProvider.tachesTerminees.isEmpty) {
            return Center(
              child: Text('Aucune tâche terminée', style: GoogleFonts.roboto(color: Colors.purple, fontSize: 24.0, fontWeight: FontWeight.bold)),
            );
          }

          // Liste des tâches terminées
          return ListView.builder(
            itemCount: tacheProvider.tachesTerminees.length,
            itemBuilder: (context, index) {

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Dismissible(
                  key: Key(tacheProvider.tachesTerminees[index].id),

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
                    tacheProvider.removeTache(tacheProvider.tachesTerminees[index]);

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
                        tacheProvider.tachesTerminees[index].titre.length > 40 // Si le titre est plus long que 40 caractères alors afficher ...
                          ? '${tacheProvider.tachesTerminees[index].titre.substring(0, 40)}...'
                          : tacheProvider.tachesTerminees[index].titre, 
                        style: GoogleFonts.acme(fontWeight: FontWeight.bold),
                      ),

                      // Date d'écheance affichée si elle existe sinon affiche "Pas de date"
                      subtitle: Text("Date d'échéance: ${tacheProvider.tachesTerminees[index].dateEcheance ?? 'Pas de date'}", style: GoogleFonts.acme()),

                      trailing: IconButton(
                        icon: Icon(
                          tacheProvider.tachesTerminees[index].importance 
                            ? CupertinoIcons.bookmark_fill 
                            : CupertinoIcons.bookmark,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // Change le statut d'importance de la tâche
                          tacheProvider.updateImportance(tacheProvider.tachesTerminees[index].id, !tacheProvider.tachesTerminees[index].importance);

                          // Affiche un SnackBar pour confirmer le changement de statut d'importance
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.purple,
                              content: Text('"${tacheProvider.tachesTerminees[index].titre}" est ${tacheProvider.tachesTerminees[index].importance ? 'non importante' : 'importante'}',
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
      
    );
  }
}