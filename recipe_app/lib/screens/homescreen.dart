import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recipe_app/random.dart';
import 'package:recipe_app/widgets/recipe_item.dart';
import '../widgets/camerabutton.dart';
import '../widgets/popular_item.dart';

import '../theme/color.dart';
import '../utils/data.dart';
import '../widgets/recommend_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        // title: _buildTitle(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          _buildHeader(),
          const SizedBox(
            height: 15,
          ),
          // _buildCategory(),
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "Popular Recipes",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
          ),
          _buildPopular(),
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "recommended Recipes",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
          ),
          _buildRecommend(),
          _buildRecommend(),
        ],
      ),
    );
  }

  // Widget _buildTitle() {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       SizedBox(
  //         width: 34,
  //         height: 34,
  //         child: IconBox(
  //           radius: 15,
  //           bgColor: appBgColor,
  //           child: SvgPicture.asset("assets/icons/menu1.svg"),
  //         ),
  //       ),
  //       // const NotificationBox(
  //       //   notifiedNumber: 1,
  //       // ),
  //     ],
  //   );
  // }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Spoonful ',
                  style: TextStyle(
                    height: 1.3,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
                TextSpan(
                  text: 'Recipes',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // int selectedCategoryIndex = 0;
  // Widget _buildCategory() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.fromLTRB(15, 5, 7, 10),
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: List.generate(
  //         categories.length,
  //         (index) => Padding(
  //           padding: const EdgeInsets.only(right: 8),
  //           child: CategoryItem(
  //             data: categories[index],
  //             isSelected: index == selectedCategoryIndex,
  //             onTap: () {
  //               setState(() {
  //                 selectedCategoryIndex = index;
  //               });
  //             },
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPopular() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 15),
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(
        populars.length,
        (index) => Container(
          margin: const EdgeInsets.only(right: 15),
          child: PopularItem(
              data: populars[index],
              onFavoriteTap: () {
                setState(() {
                  populars[index]["is_favorited"] =
                      !populars[index]["is_favorited"];
                });
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RandomRecipes()),
                );
              }),
        ),
      )),
    );
  }

  Widget _buildRecommend() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 0, 0, 15),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          recommends.length,
          (index) => Container(
            margin: const EdgeInsets.only(right: 15),
            child: RecommendItem(
              data: recommends[index],
              onTap: null,
              onFavoriteTap: () {
                setState(() {
                  recommends[index]["is_favorited"] =
                      !recommends[index]["is_favorited"];
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
