import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PlantApp(),
    );
  }
}

class PlantApp extends StatefulWidget {
  @override
  _PlantAppState createState() => _PlantAppState();
}

class _PlantAppState extends State<PlantApp> {
  List<String> plants = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPlants();
  }

  Future<void> fetchPlants() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/plants'));

      if (response.statusCode == 200) {
        setState(() {
          plants = List<String>.from(
              json.decode(response.body).map((plant) => plant['name']));
        });
      } else {
        print('Failed to load plants: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addPlant(String name) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/plants/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          plants.add(name);
        });
      } else {
        print('Failed to add plant: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plant App')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(plants[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter plant name',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_controller.text.isNotEmpty) {
                await addPlant(_controller.text);
                _controller.clear();
                await fetchPlants(); // Refresh the plant list after adding a new plant
              }
            },
            child: Text('Add Plant'),
          ),
        ],
      ),
    );
  }
}
