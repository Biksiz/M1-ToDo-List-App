import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/Models/tache_provider.dart';
import 'package:todo_list_app/Views/tache_actives.dart';
import 'package:todo_list_app/Views/taches_terminee.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MainApp> {

  static final List<Widget> _pages = <Widget>[ // liste des pages dans l'app
    const TacheActivesScreen(),
    const TacheTermineeScreen(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider( // Fournit un objet TacheProvider à l'ensemble de l'application
      create: (context) => TacheProvider(), // Crée une nouvelle instance de TacheProvider
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: _pages.elementAt(_selectedIndex),
      
          bottomNavigationBar: BottomNavigationBar( // Barre de navigation en bas
            items: const <BottomNavigationBarItem>[ // Liste des icones
      
              BottomNavigationBarItem(
                icon: Icon(Icons.check),
                label: 'Tâches actives',
              ),
      
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Tâches terminées',
              ),
      
            ],
      
            selectedItemColor: Colors.purple, // Couleur de l'icone sélectionnée
            unselectedItemColor: Colors.grey, // Couleur des icones non sélectionnées
      
            currentIndex: _selectedIndex, // Index de la page actuellement affichée
      
            onTap: (int index) { // Change la page affichée
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          
        ),
      ),
    );
  }
}