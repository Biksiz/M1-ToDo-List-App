import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/Models/tache.dart';
import 'package:todo_list_app/Models/tache_provider.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/Views/tache_details.dart';

class TacheModiferPage extends StatefulWidget {
  final Tache tache;

  const TacheModiferPage({Key? key, required this.tache}) : super(key: key);

  @override
  _TacheModiferPageState createState() => _TacheModiferPageState();
}

class _TacheModiferPageState extends State<TacheModiferPage> {
  late TextEditingController _titreController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  late TextEditingController _adresseController;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.tache.titre);
    _dateController = TextEditingController(
        text: widget.tache.dateEcheance != null
            ? widget.tache.dateEcheance.toString()
            : '');
    _descriptionController =
        TextEditingController(text: widget.tache.description ?? 'Aucune description disponible');
    _adresseController = TextEditingController(text: widget.tache.adresse ?? 'Aucune ville choisie');
  }

  // Sélectionne une date et une heure
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _dateController.text = '${_formatDate(pickedDate)} ${_formatTime(pickedTime)}';
        });
      }
    }
  }
  

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titreController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TacheProvider tacheProvider =
        Provider.of<TacheProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Modifier la tâche'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Titre:',
                style: GoogleFonts.acme(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _titreController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Date d\'échéance:',
                style: GoogleFonts.acme(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: GoogleFonts.acme(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ville :',
                style: GoogleFonts.acme(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Mettre à jour les détails de la tâche
                      widget.tache.titre = _titreController.text;
                      widget.tache.dateEcheance =
                          _dateController.text.isNotEmpty ? _dateController.text : null;
                      widget.tache.description = _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : 'Pas de description';
                      widget.tache.adresse =
                          _adresseController.text.isNotEmpty ? _adresseController.text : '';
                      widget.tache.dateModification = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

                      // Mettre à jour les détails de la tâche dans le provider
                      tacheProvider.updateTache(widget.tache);

                      Navigator.pop(context, tacheProvider.getTache(widget.tache.id));
                    },
                    child: Text(
                      'Enregistrer les modifications',
                        style: GoogleFonts.acme(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
