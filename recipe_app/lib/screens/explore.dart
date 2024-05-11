import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:recipe_app/theme/color.dart';
import 'package:recipe_app/utils/openaicode.dart';

// Import your custom files/widgets

import '../widgets/camerabutton.dart';

import 'package:camera/camera.dart';
import 'package:recipe_app/screens/campage.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late TextEditingController controller;
  late FocusNode focusNode;
  final List<String> inputTags = [];
  String response = '';
  final List<String> ingredients = [];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _navigateToCameraPage(BuildContext context) async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cameradetector(
            camera: firstCamera,
            onIngredientsDetected: (List<String> detectedIngredients) {
              setState(() {
                for (String ingredient in detectedIngredients) {
                  if (!inputTags.contains(ingredient)) {
                    // Check if ingredient is not already in the list
                    ingredients.add(ingredient);
                    inputTags.add(ingredient);
                  }
                }
              });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            snap: true,
            floating: true,
            title: _buildHeader(),
          ),
          SliverToBoxAdapter(
            child: _buildSearch(),
          ),
          SliverToBoxAdapter(
            child: _buildInputTags(),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                1, // Adjust this as per your requirement
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0),
                  child: Text(
                    response,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            if (focusNode.hasFocus) {
              setState(() {
                ingredients.add(controller.text);
                inputTags.add(controller.text);
                controller.clear();
              });
              controller.clear();
              focusNode.requestFocus();
            } else {
              setState(() => response =
                  'Let me Cook'); // Updating the response to 'Thinking'
              dynamic temp = await Response().askAi(ingredients
                  .join(ingredients.toString())); // Asking the AI for a recipe
              print(temp);
              setState(() => response = temp.toString());
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: darker,
            backgroundColor: primary,
            padding: EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Text(
            focusNode.hasFocus ? 'Add Ingredient' : 'Create Recipe',
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Explore",
          style: TextStyle(
            fontSize: 28,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
              onSubmitted: (String value) {
                setState(() {
                  ingredients.add(value);
                  controller.clear();
                  focusNode.requestFocus();
                  inputTags.add(value);
                  focusNode.requestFocus();
                });
                controller.clear();
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconBox(
            radius: 50,
            padding: 8,
            child: SvgPicture.asset(
              "assets/icons/filter1.svg",
              color: Colors.black,
              width: 18,
              height: 18,
            ),
            onTap: () {
              _navigateToCameraPage(context);
            },
            onIngredientsDetected: (List<String> detectedIngredients) {
              setState(() {
                ingredients.addAll(detectedIngredients);
                inputTags.addAll(detectedIngredients);
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildInputTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: inputTags
            .asMap()
            .entries
            .map(
              (entry) => Chip(
                label: Text(entry.value),
                onDeleted: () {
                  setState(() {
                    ingredients.remove(entry.value);
                    inputTags.remove(entry.value);
                    controller.clear();
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
