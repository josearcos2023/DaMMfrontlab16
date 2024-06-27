import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewCharacterScreen extends StatefulWidget {
  const NewCharacterScreen({Key? key}) : super(key: key);

  @override
  _NewCharacterScreenState createState() => _NewCharacterScreenState();
}

class _NewCharacterScreenState extends State<NewCharacterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  int? _selectedClassId;
  int? _selectedRaceId;

  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> races = [];

  @override
  void initState() {
    super.initState();
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
        _birthdayController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _createCharacter() async {
    final String name = _nameController.text;
    final int age = int.parse(_ageController.text);
    final String birthday = "${_selectedDate.toLocal()}".split(' ')[0];
    final int classId = _selectedClassId!;
    final int raceId = _selectedRaceId!;

    final url = Uri.parse('http://localhost:3000/api/characters');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'age': age,
        'birthday': birthday,
        'classId': classId,
        'raceId': raceId,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      throw Exception('Failed to create character');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Character'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
                onPressed: _createCharacter,
                child: const Text('Create Character'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
