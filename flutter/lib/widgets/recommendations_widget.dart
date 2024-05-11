import 'package:flutter/material.dart';
import 'package:fyp_fit3161_team8_web_app/data_classes/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp_fit3161_team8_web_app/widgets/restaurant_card.dart';
import 'package:fyp_fit3161_team8_web_app/restaurant_details_page.dart';

Future<List<Restaurant>> fetchRecommendedRestaurant(int restaurantId, int page) async {
  final response = await http.get(Uri.parse('https://api.coindesk.com/v1/bpi/currentprice.json'));

  if (response.statusCode == 200) {
    //final Map<String, dynamic> data = json.decode(response.body);

    // TEST DATA
    final Map<String, dynamic> data = {
      'restaurants': [
        {
          'restaurantId': 1,
          'name': 'VCR Cafe',
          'coverImage': 'https://www.foodadvisor.my/attachments/902c3847bc35a626f8b303f489a7f8f3d82d3b8b/store/fill/800/500/c9906624687aab259426150e9cc46cf34cd2920b2d4d262be2a54d3f0c72/featured_image.jpg',
          'status': 'Open now',
          'operatingHours': ['8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM'],
          'rating': 4.5,
          'totalReviews': 3512,
          'priceRange': 2,
          'address': '31, Jln Telawi 3, Bangsar, 59100 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur',
          'categories': ['Cafe', 'American', 'European'],
        },
        {
          'restaurantId': 2,
          'name': 'ZEN by MEL',
          'coverImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmi1L80uMKiW3ABUCMC0Zf-GbP2roGGc5Fvw&usqp=CAU',
          'status': 'Closed',
          'operatingHours': ['8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM', '8:30 AM - 11:00 PM'],
          'rating': 3.3,
          'totalReviews': 47,
          'priceRange': 3,
          'address': 'F-10-01, Pusat Perdagangan Bandar, Persiaran Jalil 1, Bukit Jalil, 57000 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur',
          'categories': ['Fine dining restaurant'],
        },
      ],
    };

    final List<dynamic> restaurants = data['restaurants'];
    return restaurants.map((json) => Restaurant.fromJson(json)).toList();
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
      widget.scrollController.animateTo(
        0.0, // Scroll to the top
        duration: Duration(milliseconds: 500), // You can adjust the duration as needed
        curve: Curves.easeInOut, // You can choose a different easing curve
      );
    }
  }

  void _loadNextRecommendationPage() {
    if (currentRecommendationPage < widget.totalPagesOfRecommendedRestaurants) {
      setState(() {
        currentRecommendationPage++;
      });
      widget.scrollController.animateTo(
        0.0, // Scroll to the top
        duration: Duration(milliseconds: 500), // You can adjust the duration as needed
        curve: Curves.easeInOut, // You can choose a different easing curve
      );
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
                    'Racommendations',
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