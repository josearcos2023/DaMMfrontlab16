import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './model_estudiante.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class EditCharacterScreen extends StatefulWidget {
  final Character character;

  const EditCharacterScreen({super.key, required this.character});

  @override
  _EditCharacterScreenState createState() => _EditCharacterScreenState();
}

class _EditCharacterScreenState extends State<EditCharacterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _birthdayController;
  int? _selectedClassId;
  int? _selectedRaceId;

  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> races = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.character.name);
    _ageController =
        TextEditingController(text: widget.character.age.toString());
    _birthdayController = TextEditingController(
        text: widget.character.birthday.toIso8601String());
    _selectedClassId = widget.character.classId;
    _selectedRaceId = widget.character.raceId;

    fetchClasses();
    fetchRaces();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = _selectedDate.toIso8601String();
      });
    }
  }

  Future<void> updateCharacter(Character updatedCharacter) async {
    final url = Uri.parse(
        'http://localhost:3000/api/characters/${updatedCharacter.id}');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(updatedCharacter.toJson()),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      print('Character updated successfully');
    } else {
      throw Exception('Failed to update character');
    }
  }

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Character'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _birthdayController,
              decoration: InputDecoration(
                labelText: 'Birthday',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
            ),
            DropdownButtonFormField<int>(
              value: _selectedClassId,
              onChanged: (newValue) {
                setState(() {
                  _selectedClassId = newValue;
                });
              },
              items: classes.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id'],
                  child: Text(item['name']),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Class'),
            ),
            DropdownButtonFormField<int>(
              value: _selectedRaceId,
              onChanged: (newValue) {
                setState(() {
                  _selectedRaceId = newValue;
                });
              },
              items: races.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id'],
                  child: Text(item['name']),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Race'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final updatedCharacter = Character(
                  id: widget.character.id,
                  name: _nameController.text,
                  age: int.parse(_ageController.text),
                  birthday: DateTime.parse(_birthdayController.text),
                  classId: _selectedClassId!,
                  raceId: _selectedRaceId!,
                );
                await updateCharacter(updatedCharacter);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
