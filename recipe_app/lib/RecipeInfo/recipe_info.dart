import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

class RecipeDetails extends StatefulWidget {
  final String recipeId;

  RecipeDetails({required this.recipeId});

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  Map<String, dynamic> details = {};

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  void fetchDetails() async {
    try {
      var response = await http.get(Uri.parse(
          'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=66ff906cd6fc4f3dba34e375df936e59'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          details = data;
        });
      } else {
        throw Exception('Failed to load recipe details');
      }
    } catch (error) {
      print('Error fetching recipe details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(details['title'] ?? 'Recipe Details'),
      ),
      body: details.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        details['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    details['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      // Save Recipe function
                    },
                    child: Text('Save Recipe'),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Ingredients',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: details['extendedIngredients']
                        .map<Widget>((ingredient) {
                      return Text(
                        ingredient['original'],
                        style: TextStyle(fontSize: 16.0),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Instructions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Html(
                    data: details['summary'],
                  ),
                  SizedBox(height: 10.0),
                  Html(
                    data: details['instructions'],
                  ),
                ],
              ),
            ),
    );
  }
}
