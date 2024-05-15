import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/Models/tache.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_list_app/Models/tache_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

import 'package:todo_list_app/Views/tache_modifier.dart';

class TacheDetailsPage extends StatefulWidget {
  final Tache tache;

  const TacheDetailsPage({super.key, required this.tache});

  @override
  // ignore: library_private_types_in_public_api
  _TacheDetailsPageState createState() => _TacheDetailsPageState();
}

class _TacheDetailsPageState extends State<TacheDetailsPage> {

  double latitude = 0.0;
  double longitude = 0.0;
  bool weatherDescription = false;
  bool weatherErreurApi = false;
  String imageURI = '';
  String meteoTemp = '';
  String meteoDescription = '';
  // Clé d'API OpenWeatherMap
  final String apiKey = 'e389d80121e619b4c628c13145e38715';

  // Fonction pour récupérer les données météorologiques
  Future<void> fetchWeather() async {
    List<Location> locations = await locationFromAddress(widget.tache.adresse!);

    latitude = locations[0].latitude;
    longitude = locations[0].longitude;

    String? dateEcheance = widget.tache.dateEcheance;
    DateTime parsedDate = DateTime.parse(dateEcheance!);

    int year = parsedDate.year;
    int month = parsedDate.month;
    int day = parsedDate.day;
    int hour = parsedDate.hour;
    int minute = parsedDate.minute;
    

    int timestamp = DateTime(year, month, day, hour, minute).millisecondsSinceEpoch ~/ 1000;
    int timestampInMilliseconds = timestamp * 1000;

    // Construire l'URL de l'API OpenWeatherMap
    String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';
    String queryParams =
        '?lat=$latitude&lon=$longitude&dt=$timestampInMilliseconds&appid=$apiKey&units=metric&lang=fr';
    String url = apiUrl + queryParams;

    // Faire la requête à l'API OpenWeatherMap
    var response = await http.get(Uri.parse(url));

    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> meteoData = json.decode(response.body);

      String imageId = meteoData['weather'][0]['icon'];

      setState(() {
        weatherDescription = true;
        latitude = latitude;
        longitude = longitude;
        meteoTemp = '${meteoData['main']['temp']}';
        meteoDescription = meteoData['weather'][0]['description'];
        imageURI = 'http://openweathermap.org/img/w/$imageId.png';
      });
    } else {
      // En cas d'erreur de la requête
      setState(() {
        weatherDescription = false;
        weatherErreurApi = true;
        latitude = latitude;
        longitude = longitude;
      });
    }
  }

  


  Widget currentWeather(String imageURI, String ville, String meteoTemp, String meteoDescription) {
    return Column(
      children: [
        Image.network(imageURI),
        const SizedBox(height: 10),
        Text(
          meteoDescription,
          style: TextStyle(fontSize: 23.0),
        ),
        Text(
          '$meteoTemp°C',
          style: TextStyle(fontSize: 46.0),
        ),
        const SizedBox(height: 10),
        Text(
          ville,
          style: GoogleFonts.acme(
              fontWeight: FontWeight.bold, color: Color(0xFF5a5a5a)),
        ),
      ],
    );
  }


  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    TacheProvider tacheProvider =
        Provider.of<TacheProvider>(context, listen: false);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.purple,
              iconTheme: const IconThemeData(
                  color: Colors.white), // Couleur de l'icone
              actions: [
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TacheModiferPage(tache: widget.tache)),
                    );
                    setState(() {
                      fetchWeather();
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white),
                      const SizedBox(
                          width: 5), // Espacement entre l'icône et le texte
                      Text(
                        'Modifier',
                        style: GoogleFonts.acme(
                                fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(
                            widget.tache.titre,
                            style: GoogleFonts.acme(
                                fontWeight: FontWeight.bold, fontSize: 26),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(), // Espace flexible à gauche de l'icône
                              IconButton(
                                icon: Icon(
                                  widget.tache.importance
                                      ? CupertinoIcons.bookmark_fill
                                      : CupertinoIcons.bookmark,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  // Change le statut d'importance de la tâche
                                  tacheProvider.updateImportance(
                                      widget.tache.id,
                                      !widget.tache.importance);
                                  setState(() {});

                                  // Affiche un SnackBar pour confirmer le changement de statut d'importance
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.purple,
                                      content: Text(
                                        '"${widget.tache.titre}" est ${widget.tache.importance ? 'non importante' : 'importante'}',
                                        style: GoogleFonts.roboto(
                                            color: Colors.white),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                  width:
                                      10), // Espace entre l'icône et le bouton

                              // Bouton pour marquer la tâche comme terminée ou non terminée
                              TextButton(
                                onPressed: () {
                                  // Change le statut de terminée de la tâche
                                  tacheProvider.updateTerminee(
                                      widget.tache.id, !widget.tache.terminee);
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: widget.tache.terminee
                                        ? Colors.green
                                        : Colors
                                            .red, // Couleur de fond basée sur l'état de la tâche
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.tache.terminee
                                        ? 'Terminée'
                                        : 'Non terminée',
                                    style: GoogleFonts.acme(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              const Spacer(), 
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const TabBar(
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.purple,
                  tabs: [
                    Tab(
                      text: 'Informations',
                    ),
                    Tab(
                      text: 'Carte',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Center(
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Date d'echéance :",
                                          style: GoogleFonts.acme(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple),
                                        ),
                                        Text(
                                          widget.tache.dateEcheance ?? "Date d'echeance inconnue",
                                          style: GoogleFonts.acme(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20, thickness: 1),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Date de dernière modification :",
                                          style: GoogleFonts.acme(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple),
                                        ),
                                        Text(
                                          widget.tache.dateModification.substring(0, 16),
                                          style: GoogleFonts.acme(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20, thickness: 1),
                                  ],
                                ),
                                Text(
                                  "Description :",
                                  style: GoogleFonts.acme(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical : 8.0),
                                  child :Text(
                                    widget.tache.description ?? "Pas de description",
                                    style: GoogleFonts.acme(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Divider(height: 20, thickness: 1),
                                Row(
                                  children: [
                                    Text(
                                      "Météo :",
                                      style: GoogleFonts.acme(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple),
                                    ),
                                    Text(
                                      '   (Il faut une ville et une date pour afficher la météo)',
                                      style: GoogleFonts.acme(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: 
                                      weatherDescription
                                          ? currentWeather(imageURI, widget.tache.adresse ?? "Adresse inconnue", meteoTemp, meteoDescription)
                                          : weatherErreurApi
                                              ? const Text('Erreur lors de la récupération de la météo')
                                              : const CircularProgressIndicator(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding : const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Ville :",
                                          style: GoogleFonts.acme(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple),
                                        ),
                                        Text(
                                          widget.tache.adresse ?? "Adresse inconnue",
                                          style: GoogleFonts.acme(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20, thickness: 1),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: SizedBox(
                                        height: 300, 
                                        width: double.infinity, 
                                        child: FlutterMap(
                                          options: MapOptions(
                                            interactionOptions: const InteractionOptions(
                                              enableMultiFingerGestureRace: true,
                                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                                            ),
                                            initialCenter: LatLng(latitude, longitude), 
                                            initialZoom: 15.0,
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                              userAgentPackageName: 'comm.example.app',
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                Marker(
                                                  point: LatLng(latitude, longitude), 
                                                  child: Icon(Icons.location_on, color: Colors.purple, size: 40),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
