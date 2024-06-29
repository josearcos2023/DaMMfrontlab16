import 'package:flutter/material.dart';
import 'package:frontlab16/edit_character.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'model_estudiante.dart';
import 'new_character.dart';

class CharacterTableScreen extends StatefulWidget {
  const CharacterTableScreen({super.key});

  @override
  _CharacterTableScreenState createState() => _CharacterTableScreenState();
}

class _CharacterTableScreenState extends State<CharacterTableScreen> {
  List<Character> characters = [];

  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> races = [];

  void navigateToNewCharacterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewCharacterScreen()),
    ).then((_) {
      fetchCharacters();
    });
  }

  void navigateToEditCharacterScreen(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditCharacterScreen(character: character)),
    ).then((_) {
      // Refrescar la lista de personajes después de regresar de la pantalla de edición
      fetchCharacters();
    });
  }

  Future<void> fetchCharacters() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/characters'));
    if (response.statusCode == 200) {
      List<Character> fetchedCharacters = (json.decode(response.body) as List)
          .map((data) => Character.fromJson(data))
          .toList();
      setState(() {
        characters = fetchedCharacters;
      });
    } else {
      throw Exception('Failed to load characters');
    }
  }

  Future<void> fetchClasses() async {
    final url = Uri.parse('http://localhost:3000/api/classes');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        classes = data
            .map((item) => {'id': item['id'], 'name': item['name']})
            .toList();
      });
    } else {
      throw Exception('Failed to load classes');
    }
  }

  Future<void> fetchRaces() async {
    final url = Uri.parse('http://localhost:3000/api/races');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        races = data
            .map((item) => {'id': item['id'], 'name': item['name']})
            .toList();
      });
    } else {
      throw Exception('Failed to load races');
    }
  }

  String getClassName(int classId) {
    final classItem = classes.firstWhere((element) => element['id'] == classId,
        orElse: () => {'name': 'Unknown'});
    return classItem['name'];
  }

  String getRaceName(int raceId) {
    final raceItem = races.firstWhere((element) => element['id'] == raceId,
        orElse: () => {'name': 'Unknown'});
    return raceItem['name'];
  }

  Future<void> deleteCharacter(int id) async {
    final url = Uri.parse('http://localhost:3000/api/characters/$id');
    final response = await http.delete(url);
    if (response.statusCode == 204) {
      setState(() {
        characters.removeWhere((character) => character.id == id);
      });
    } else {
      throw Exception('Failed to delete character');
    }
  }

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    fetchCharacters();
    fetchClasses();
    fetchRaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Age')),
              DataColumn(label: Text('Birthday')),
              DataColumn(label: Text('Class')),
              DataColumn(label: Text('Race')),
              DataColumn(label: Text('Eliminar')),
              DataColumn(label: Text('Editar')),
            ],
            rows: characters
                .map((character) => DataRow(
                      cells: [
                        DataCell(Text(character.name)),
                        DataCell(Text(character.age.toString())),
                        DataCell(
                            Text(formatDate(character.birthday.toString()))),
                        DataCell(Text(getClassName(character.classId))),
                        DataCell(Text(getRaceName(character.raceId))),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteCharacter(character.id!);
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              navigateToEditCharacterScreen(character);
                            },
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToNewCharacterScreen,
        tooltip: 'Add Character',
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CharacterTableScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
