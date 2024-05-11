import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipe_app/recipe_info.dart';

class RandomRecipes extends StatefulWidget {
  @override
  _RandomRecipesState createState() => _RandomRecipesState();
}

class _RandomRecipesState extends State<RandomRecipes> {
  List<dynamic> randomRecipes = [];

  @override
  void initState() {
    super.initState();
    getRandomRecipes();
  }

  void getRandomRecipes() async {
    try {
      var response = await http.get(Uri.parse(
          'https://api.spoonacular.com/recipes/random?apiKey=66ff906cd6fc4f3dba34e375df936e59&number=10'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          randomRecipes = data['recipes'];
        });
      } else {
        throw Exception('Failed to load random recipes');
      }
    } catch (error) {
      print('Error fetching random recipes: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Let\'s Eat!!!'),
      ),
      body: randomRecipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: randomRecipes.length,
              itemBuilder: (context, index) {
                var recipe = randomRecipes[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetails(
                              recipeId: recipe['id'].toString(),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.0)),
                            child: Image.network(
                              recipe['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              recipe['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RandomRecipes(),
  ));
}
