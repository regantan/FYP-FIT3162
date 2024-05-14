import 'package:flutter/material.dart';
import 'package:fyp_fit3161_team8_web_app/data_classes/restaurant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp_fit3161_team8_web_app/widgets/restaurant_card.dart';
import 'package:fyp_fit3161_team8_web_app/restaurant_details_page.dart';

Future<List<Restaurant>> fetchRecommendedRestaurant(int restaurantId, int page) async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8079/api/recommended_restaurants/kl/${page}'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    // TEST DATA
    // final Map<String, dynamic> data = {
    //   'restaurants': [
    //     {
    //       'id': 1,
    //       'restaurant_name': "Iketeru Restaurant",
    //       'coverImage': 'https://www.foodadvisor.my/attachments/902c3847bc35a626f8b303f489a7f8f3d82d3b8b/store/fill/800/500/c9906624687aab259426150e9cc46cf34cd2920b2d4d262be2a54d3f0c72/featured_image.jpg',
    //       'cuisine': ['Cafe', 'American', 'European'],
    //       'star_rating': 5,
    //       'no_reviews': 2412,
    //       'trip_advisor_url': "https://www.tripadvisor.com.my/Restaurant_Review-g298570-d796300-Reviews-Iketeru_Restaurant-Kuala_Lumpur_Wilayah_Persekutuan.html",
    //     },
    //     {
    //       'id': 2,
    //       'restaurant_name': "Iketeru Restaurant",
    //       'coverImage': 'https://www.foodadvisor.my/attachments/902c3847bc35a626f8b303f489a7f8f3d82d3b8b/store/fill/800/500/c9906624687aab259426150e9cc46cf34cd2920b2d4d262be2a54d3f0c72/featured_image.jpg',
    //       'cuisine': ['Cafe', 'American', 'European'],
    //       'star_rating': 5,
    //       'no_reviews': 2412,
    //       'trip_advisor_url': "https://www.tripadvisor.com.my/Restaurant_Review-g298570-d796300-Reviews-Iketeru_Restaurant-Kuala_Lumpur_Wilayah_Persekutuan.html",
    //     },
    //   ],
    // };

    // final List<dynamic> restaurants = data['restaurants'];
    // return restaurants.map((json) => Restaurant.fromJson(json)).toList();
    return data.map((json) => Restaurant.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load recommended restaurants');
  }
}

class RecommendationsWidget extends StatefulWidget {

  final int restaurantId;
  final int totalPagesOfRecommendedRestaurants;
  final ScrollController scrollController;

  const RecommendationsWidget({Key? key,
    required this.restaurantId, required this.totalPagesOfRecommendedRestaurants, required this.scrollController})
      : super(key: key);

  @override
  _RecommendationsWidgetState createState() => _RecommendationsWidgetState();
}

class _RecommendationsWidgetState extends State<RecommendationsWidget> {
  int currentRecommendationPage = 1;

  void _loadPreviousRecommendationPage() {
    if (currentRecommendationPage > 1) {
      setState(() {
        currentRecommendationPage--;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController.animateTo(
          0.0, // Scroll to the top
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _loadNextRecommendationPage() {
    if (currentRecommendationPage < widget.totalPagesOfRecommendedRestaurants) {
      setState(() {
        currentRecommendationPage++;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController.animateTo(
          0.0, // Scroll to the top
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0, left: 6.0, right: 6.0),
      child: FutureBuilder<List<Restaurant>>(
        future: fetchRecommendedRestaurant(widget.restaurantId, currentRecommendationPage),
        builder: (context, snapshot) {
          print('Fetch recommended restaurant');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.secondary,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No restaurant recommendations available.'),
            );
          } else {
            final List<Restaurant>? restaurants = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    'Recommendations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var restaurant in restaurants!)
                      Container(
                        constraints: BoxConstraints(maxHeight: 400.0),
                        child: AspectRatio(
                          aspectRatio: 370 / 400,
                          child: RestaurantCard(
                              restaurant: restaurant,
                              onCardTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantDetailsPage(
                                      restaurantId: restaurant.restaurantId,
                                      restaurantName: restaurant.name,
                                    ),
                                  ),
                                );
                                debugPrint('Restaurant recommendations clicked');
                              }
                          ),
                        ),
                      ),
                    SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _loadPreviousRecommendationPage();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios, // You can use any icon you want here
                            size: 25.0, // Adjust the size as needed
                            color: Colors.black, // Change the color as needed
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('${currentRecommendationPage.toString()}-${widget.totalPagesOfRecommendedRestaurants.toString()}',
                            style: TextStyle(
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _loadNextRecommendationPage();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios, // You can use any icon you want here
                            size: 25.0, // Adjust the size as needed
                            color: Colors.black, // Change the color as needed
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}