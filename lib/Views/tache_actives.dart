import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list_app/Views/tache_details.dart';
import 'package:uuid/uuid.dart';
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
  String? dropdownValue = 'Trier: Importance';

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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
              items: <String>['Trier: Importance', 'Trier: Date d\'échéance']
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

          // Variable pour stocker la méthode de tri
          Function(List<Tache>) methodeTrie = tacheProvider.triParDefaut;

          // Si la valeur du dropdown est 'Trier: Importance' alors trier par importance sinon trier par date d'échéance
          if (dropdownValue == 'Trier: Importance') {
            methodeTrie = tacheProvider.triParDefaut;
          } 
          else {
            // Tri par date d'échéance puis par date de modification en cas d'égalité
            methodeTrie = tacheProvider.triParDateEcheance;
          }

          return FutureBuilder<List<Tache>>(
            future: tacheProvider.getTachesActives(methodeTrie), //dropdownValue
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {

                // Afficher un cercle de chargement si les favoris sont en cours de chargement
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: CircularProgressIndicator(),
                );

              }

              // Si la liste des tâches actives est vide
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text('Aucune tâche active', style: GoogleFonts.roboto(color: Colors.purple, fontSize: 24.0, fontWeight: FontWeight.bold)),
                );
              }

              // Liste des tâches actives
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Dismissible(
                      key: Key(snapshot.data![index].id),

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

                      // Lorsqu'on swipe pour supprimer une tâche on s'assure que la suppression est souhaitée
                      confirmDismiss: (direction) async {

                        // AlertDialog pour la confirmation de la suppression
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {

                            return AlertDialog(

                              title: Text('Êtes-vous sûr de vouloir supprimer cette tâche ?',
                                style: GoogleFonts.racingSansOne(color: Colors.purple),
                                textAlign: TextAlign.center,
                              ),

                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    
                                    // Bouton pour annuler
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      ),
                                      child: const Text('Annuler'),
                                      onPressed: () {
                                    
                                        // Ferme l'AlertDialog et indique que la tâche n'a pas été supprimée
                                        Navigator.of(context).pop(false);
                                    
                                      },
                                    ),


                                    // Bouton pour confirmer la suppression
                                    ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      ),
                                      child: const Text('Confirmer'),
                                      onPressed: () {

                                        // Supprime la tâche
                                        tacheProvider.removeTache(snapshot.data![index]);

                                        // Ferme l'AlertDialog et indique que la tâche a été supprimée
                                        Navigator.of(context).pop(true);

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
                                    ),

                                  ],
                                ),
                              ],
                            );
                          },
                        );

                      },

                      child: Card(
                        color: Colors.purpleAccent.withOpacity(0.2),

                        child: ListTile(
                          title: Text(
                            snapshot.data![index].titre.length > 40 // Si le titre est plus long que 40 caractères alors afficher ...
                              ? '${snapshot.data![index].titre.substring(0, 40)}...'
                              : snapshot.data![index].titre, 
                            style: GoogleFonts.acme(fontWeight: FontWeight.bold),
                          ),

                          // Date d'écheance affichée si elle existe sinon affiche "Pas de date"
                          subtitle: Text("Date d'échéance: ${snapshot.data![index].dateEcheance ?? 'Pas de date'}", style: GoogleFonts.acme()),

                          trailing: IconButton(
                            icon: Icon(
                              snapshot.data![index].importance 
                                ? CupertinoIcons.bookmark_fill 
                                : CupertinoIcons.bookmark,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              // Change le statut d'importance de la tâche
                              tacheProvider.updateImportance(snapshot.data![index].id, !snapshot.data![index].importance);

                              // Affiche un SnackBar pour confirmer le changement de statut d'importance
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.purple,
                                  content: Text('"${snapshot.data![index].titre}" est ${snapshot.data![index].importance ? 'non importante' : 'importante'}',
                                    style: GoogleFonts.roboto(color: Colors.white),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );

                            },
                          ),
                          onTap: () {
                            // Naviguer vers la page de détails avec les données de la tâche
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TacheDetailsPage(tache: snapshot.data![index])),
                            );
                          },
                        ),
                      ),

                    ),
                  );

                },
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
                        id : const Uuid().v4(),
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