import 'package:flutter/material.dart';
import 'package:fyp_fit3161_team8_web_app/widgets/restaurant_detailed_information_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'widgets/ratings_and_reviews_widget.dart';
import 'data_classes/restaurant_details.dart';
import 'widgets/recommendations_widget.dart';

/**
 * Fetches restaurant details from the API
 */
Future<RestaurantDetails> fetchRestaurantDetails(int restaurantId) async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8079/api/restaurant_details/${restaurantId}'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    // TEST DATA
    // final Map<String, dynamic> data = {
    //   'restaurantId': 1,
    //   'name': 'VCR Cafe',
    //   'coverImage': 'https://1.bp.blogspot.com/-8z3AlAEUiIc/XXEho3EiRtI/AAAAAAACjp4/VtJyYjtGIZIplaFWQgQ98df6MpNnRe_owCLcBGAs/s1600/L1000346.jpg',
    //   'rating': 4.5,
    //   'totalReviews': 100,
    //   'fullAddress': '123 Main Street, City, State, Zip Code',
    //   'categories': ['American', 'Asian'],
    //   'websiteUrl': 'https://www.example.com',
    //   'phoneNumber': '123-456-7890',
    //   'aspectsSummary': [
    //     {
    //       'aspectName': 'Entertainment',
    //       'positivity': 1,
    //     },
    //     {
    //       'aspectName': 'Service',
    //       'positivity': 0,
    //     },
    //     {
    //       'aspectName': 'Food',
    //       'positivity': 1,
    //     },
    //     {
    //       'aspectName': 'Ambience',
    //       'positivity': 0,
    //     },
    //   ],
    //   'totalPagesOfReviews': 20,
    //   'totalPagesOfRecommendedRestaurants': 5,
    // };

    return RestaurantDetails.fromJson(data);
  } else {
    throw Exception('Failed to load restaurant details');
  }
}

Color getColorFromPositivity(double positivity) {
  Color? red = Colors.red[600];
  Color? lightRed = Colors.red[300];
  Color? green = Colors.green[600];
  Color? lightGreen = Colors.green[300];
  Color neutral = Colors.grey;

  if (positivity == 0.0) {
    return neutral;
  } else if (positivity < 0) {
    // Calculate how far the value is between -1 and 0
    return Color.lerp(red, lightRed, positivity.abs())!;
  } else {
    // Calculate how far the value is between 0 and 1
    return Color.lerp(lightGreen, green, positivity)!;
  }
}

/**
 * Restaurant details page
 */
class RestaurantDetailsPage extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;

  const RestaurantDetailsPage(
      {Key? key,
        required this.restaurantId, required this.restaurantName})
      : super(key: key);

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

/**
 * State of the restaurant details page
 */
class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {

  ScrollController _scrollController = ScrollController();
  bool _isFindSimilarRestaurantActivated = false;

  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context);
    var style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
      fontSize: 16,
    );
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: GestureDetector(
            onTap: () {
              // Pop all previous pages and return to the main page (main.dart)
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('RestoReview')
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 10.0,
          bottom: 10.0,
          left: 16.0,
          right: 16.0,
        ),
        child: FutureBuilder<RestaurantDetails>(
          future: fetchRestaurantDetails(widget.restaurantId),
          builder: (context, snapshot) {
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
                child: Text('No restaurant details available.'),
              );
            } else {
              // Storing restaurant details
              final RestaurantDetails? restaurantDetails = snapshot.data;

              return SingleChildScrollView(
                controller: _scrollController,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurantDetails!.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating: restaurantDetails.rating.toDouble(),
                                          minRating: 7,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 16,
                                          itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          ignoreGestures: true, onRatingUpdate: (double value) {  },
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                    Text(
                                      '${restaurantDetails.rating.toString()} (${NumberFormat.compact().format(restaurantDetails.totalReviews).toString()} reviews)',
                                      style: style,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 70,
                                  width: screenWidth - 250,
                                  child: Expanded(
                                    child: GridView(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 5,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                        childAspectRatio: 240 / 40,
                                      ),
                                      children: restaurantDetails.aspectsSummary
                                          .where((aspect) => aspect['aspectName'] != null && aspect['aspectName'].isNotEmpty)
                                          .map((aspectSummary) => Tooltip(
                                        message: '${aspectSummary['aspectName'].replaceAll(RegExp(r'[#]'), ': ').trim()} | ${(aspectSummary['positivity']*100).toInt()}%',
                                        child: Container(
                                          width: 240,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: getColorFromPositivity(aspectSummary['positivity']),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                            child: Center(
                                              child: Text(
                                                '${aspectSummary['aspectName'].replaceAll(RegExp(r'[#]'), ': ').trim()} | ${(aspectSummary['positivity']*100).toInt()}%',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                          )).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Spacer(),
                            // Container(
                            //   height: 100,
                            //   width: 270,
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     children: [
                            //       Text(
                            //         'Review Summary',
                            //         style: TextStyle(
                            //           fontWeight: FontWeight.bold,
                            //           fontSize: 20,
                            //           overflow: TextOverflow.ellipsis,
                            //         ),
                            //       ),
                            //       Expanded(
                            //         child: GridView(
                            //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            //             crossAxisCount: 2,
                            //             crossAxisSpacing: 5,
                            //             mainAxisSpacing: 5,
                            //             childAspectRatio: 120 / 25,
                            //           ),
                            //           children: restaurantDetails.aspectsSummary
                            //               .where((aspect) => aspect['aspectName'] != null && aspect['aspectName'].isNotEmpty)
                            //               .map((aspectSummary) => Container(
                            //             width: 120,
                            //             height: 25,
                            //             decoration: BoxDecoration(
                            //               color: getColorFromPositivity(double.parse(aspectSummary['positivity'])),
                            //               borderRadius: BorderRadius.circular(20.0),
                            //             ),
                            //             child: Padding(
                            //               padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                            //               child: Center(
                            //                 child: Text(
                            //                   aspectSummary['aspectName'].replaceAll(RegExp(r'[#_]'), ' ').trim(),
                            //                   style: TextStyle(
                            //                     color: Colors.white,
                            //                     fontSize: 14,
                            //                     fontWeight: FontWeight.bold,
                            //                     overflow: TextOverflow.ellipsis,
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           )).toList(),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // AspectRatio(
                                    //   aspectRatio: 16 / 9,
                                    //   child: ClipRRect(
                                    //     borderRadius: BorderRadius.circular(15.0),
                                    //     child: CachedNetworkImage(
                                    //       imageUrl: restaurantDetails.coverImage,
                                    //       fit: BoxFit.cover,
                                    //       placeholder: (context, url) => Image.asset(
                                    //         'assets/images/image_placeholder.jpg',
                                    //         fit: BoxFit.cover,
                                    //       ),
                                    //       errorWidget: (context, url, error) => Container(
                                    //           child: Icon(
                                    //             Icons.error,
                                    //             size: 50,
                                    //           )
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(height: 10),
                                    RestaurantDetailedInformationWidget(restaurantDetails: restaurantDetails),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: RatingsAndReviewsWidget(
                                  restaurantId: restaurantDetails.restaurantId,
                                  totalPagesOfReviews: restaurantDetails.totalPagesOfReviews,
                                  scrollController: _scrollController,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Visibility(
                                visible: !_isFindSimilarRestaurantActivated,
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 200.0),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _isFindSimilarRestaurantActivated = true;
                                          });
                                        },
                                        child: Text(
                                          'Find Similar Restaurants',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                replacement: RecommendationsWidget(
                                  restaurantId: restaurantDetails.restaurantId,
                                  totalPagesOfRecommendedRestaurants: restaurantDetails.totalPagesOfRecommendedRestaurants,
                                  scrollController: _scrollController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                ),
              );
            }
          },
        ),
      ),
    );
  }
}