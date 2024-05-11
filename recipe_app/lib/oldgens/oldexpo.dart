// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:recipe_app/utils/openaicode.dart';

// // Import your custom files/widgets
// import '../../theme/color.dart';
// import '../../utils/data.dart';
// import '../../widgets/category_item.dart';
// import '../../widgets/custom_round_textbox.dart';
// import '../widgets/camerabutton.dart';
// import 'package:http/http.dart' as http;

// class ExplorePage extends StatefulWidget {
//   const ExplorePage({Key? key}) : super(key: key);

//   @override
//   _ExplorePageState createState() => _ExplorePageState();
// }

// class _ExplorePageState extends State<ExplorePage> {
//   late TextEditingController controller;
//   late FocusNode focusNode;
//   final List<String> inputTags = [];
//   String response = '';
//   bool showButton = false;
//   late String responseMessage = '';
//   final List<String> ingredients = <String>[];

//   @override
//   void initState() {
//     super.initState();
//     controller = TextEditingController();
//     focusNode = FocusNode();
//     focusNode.addListener(() {
//       setState(() {
//         showButton = focusNode.hasFocus;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: <Widget>[
//           SliverAppBar(
//             backgroundColor: appBgColor,
//             pinned: true,
//             snap: true,
//             floating: true,
//             title: _buildHeader(),
//           ),
//           SliverToBoxAdapter(
//             child: _buildSearch(),
//           ),
//           // SliverToBoxAdapter(
//           //   child: _buildCategory(),
//           // ),
//           SliverToBoxAdapter(
//             child: _buildInputTags(),
//           ),
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: List.generate(
//                 1, // Adjust this as per your requirement
//                 (index) => Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 15.0, vertical: 8.0),
//                   child: Text(
//                     response,
//                     style: TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.normal,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           onPressed: () async {
//             if (focusNode.hasFocus) {
//               setState(() {
//                 ingredients.add(controller.text);
//                 inputTags.add(controller.text);
//                 controller.clear(); // Clearing the text field
//               });
//               controller.clear();
//               focusNode.requestFocus();
//             } else {
//               setState(() => response =
//                   'Let me Cook'); // Updating the response to 'Thinking'
//               dynamic temp = await Response().askAi(ingredients
//                   .join(ingredients.toString())); // Asking the AI for a recipe
//               print(temp);
//               setState(() => response = temp.toString());
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             foregroundColor: darker,
//             backgroundColor: primary,
//             padding: EdgeInsets.symmetric(
//               horizontal: 40,
//               vertical: 16,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30.0),
//             ),
//           ),
//           child: Text(
//             focusNode.hasFocus ? 'Add Ingredient' : 'Create Recipe',
//           ),
//         ),
//       ),
//     );
//   }

//   // Future<void> fetchAndDisplayRecipes(String ingredients) async {
//   //   try {
//   //     String result = await fetchRecipes(ingredients);
//   //     setState(() {
//   //       responseMessage = result;
//   //     });
//   //   } catch (e) {
//   //     setState(() {
//   //       responseMessage = 'Error: $e';
//   //       print(e);
//   //     });
//   //   }
//   // }

//   Widget _buildHeader() {
//     return const Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           "Explore",
//           style: TextStyle(
//             fontSize: 28,
//             color: Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearch() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: controller,
//               focusNode: focusNode,
//               decoration: const InputDecoration(
//                 hintText: "Search",
//                 prefixIcon: Icon(Icons.search, color: Colors.grey),
//               ),
//               onSubmitted: (String value) {
//                 setState(() {
//                   ingredients.add(value); // Adding the ingredient to the list
//                   controller.clear(); // Clearing the text field
//                   focusNode.requestFocus();
//                   inputTags.add(value);
//                   focusNode.requestFocus();
//                 });
//                 controller.clear();
//               },
//             ),
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//           IconBox(
//             radius: 50,
//             padding: 8,
//             child: SvgPicture.asset(
//               "assets/icons/filter1.svg",
//               color: darker,
//               width: 18,
//               height: 18,
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   int selectedCategoryIndex = 0;
//   Widget _buildCategory() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(15, 5, 7, 20),
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: List.generate(
//           categories.length,
//           (index) => Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: CategoryItem(
//               padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
//               data: categories[index],
//               isSelected: index == selectedCategoryIndex,
//               onTap: () {
//                 setState(() {
//                   selectedCategoryIndex = index;
//                 });
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputTags() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Wrap(
//         spacing: 8.0,
//         runSpacing: 4.0,
//         children: inputTags
//             .asMap()
//             .entries
//             .map(
//               (entry) => CustomChip(
//                 label: entry.value,
//                 onDelete: () {
//                   setState(() {
//                     // Remove ingredient from both lists
//                     ingredients.remove(entry.value);
//                     inputTags.remove(entry.value);
//                     controller.clear(); // Clear text field
//                   });
//                 },
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }
