import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

/**
 * This is the data class for storing the ratings and reviews of a restaurant
 */
class RestaurantReviews {
  final int restaurantId;
  final double rating;
  final int totalReviews;
  final List<dynamic> reviews;

  RestaurantReviews({
    required this.restaurantId,
    required this.rating,
    required this.totalReviews,
    required this.reviews,
  });

  factory RestaurantReviews.fromJson(Map<String, dynamic> json) {
    return RestaurantReviews(
      restaurantId: json['restaurantId'],
      rating: json['rating'],
      totalReviews: json['totalReviews'],
      reviews: json['reviews'],
    );
  }
}

/**
 * The function to fetch the restaurant's ratings and reviews information
 */
Future<RestaurantReviews> fetchRestaurantReviews(int restaurantId, int page) async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8079/api/reviews/${restaurantId}/${page}'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    // TEST DATA
    // final Map<String, dynamic> data = {
    //   'restaurantId': 1,
    //   'rating': 4.5,
    //   'totalReviews': 100,
    //   'reviews': [
    //     {
    //       'reviewId': 1,
    //       'reviewerName': 'John Doe',
    //       'reviewDate': '2021-09-01',
    //       'rating': 3.5,
    //       'reviewText': 'The stuff in this place is great! Every one of them had given us a big smile when we entered with a warm "Welcome!"',
    //       'aspectReviews': [
    //         {
    //           'aspectId': 1,
    //           'aspectName': 'Food',
    //           'positivity': 1,
    //         },
    //         {
    //           'aspectId': 2,
    //           'aspectName': 'Service',
    //           'positivity': 0,
    //         },
    //       ],
    //     },
    //     {
    //       'reviewId': 2,
    //       'reviewerName': 'Alice Looi',
    //       'reviewDate': '2022-10-01',
    //       'rating': 4.5,
    //       'reviewText': 'The stuff in this place is great! Every one of them had given us a big smile when we entered with a warm "Welcome!"',
    //       'aspectReviews': [
    //         {
    //           'aspectId': 1,
    //           'aspectName': 'Food',
    //           'positivity': 0,
    //         },
    //         {
    //           'aspectId': 2,
    //           'aspectName': 'Service',
    //           'positivity': 1,
    //         },
    //         {
    //           'aspectId': 3,
    //           'aspectName': 'Environment',
    //           'positivity': 1,
    //         },
    //       ],
    //     },
    //   ],
    // };

    return RestaurantReviews.fromJson(data);
  } else {
    throw Exception('Failed to load restaurant reviews');
  }
}

/**
 * Restaurant's ratings and reviews widget
 */
class RatingsAndReviewsWidget extends StatefulWidget {

  final int restaurantId;
  final int totalPagesOfReviews;
  final ScrollController scrollController;

  const RatingsAndReviewsWidget({Key? key,
    required this.restaurantId, required this.totalPagesOfReviews, required this.scrollController})
      : super(key: key);

  @override
  _RatingsAndReviewsWidgetState createState() => _RatingsAndReviewsWidgetState();
}

/**
 * The state of the restaurant's ratings and reviews widget
 */
class _RatingsAndReviewsWidgetState extends State<RatingsAndReviewsWidget> {
  int currentReviewPage = 1;

  /**
   * Method to load the previous page of reviews
   */
  void _loadPreviousPageOfReviews() {
    if (currentReviewPage > 1) {
      setState(() {
        currentReviewPage--;
      });
      widget.scrollController.animateTo(
        0.0, // Scroll to the top
        duration: Duration(milliseconds: 500), // You can adjust the duration as needed
        curve: Curves.easeInOut, // You can choose a different easing curve
      );
    }
  }

  /**
   * Method to load the next pages of reviews
   */
  void _loadNextPageOfReviews() {
    if (currentReviewPage < widget.totalPagesOfReviews) {
      setState(() {
        currentReviewPage++;
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
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder<RestaurantReviews>(
        future: fetchRestaurantReviews(widget.restaurantId, currentReviewPage),
        builder: (context, snapshot) {
          print('Fetch restaurant reviews');
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator when still loading
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.secondary,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // Display an error message
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            // Display a message when no restaurant reviews are found
            return Center(
              child: Text('No restaurant reviews available.'),
            );
          } else {
            final RestaurantReviews? restaurantReviews = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ratings and Reviews',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      restaurantReviews!.rating.toString(),
                      style: TextStyle(
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '(${NumberFormat('#,###').format(restaurantReviews.totalReviews).toString()})',
                      style: TextStyle(
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                for (var review in restaurantReviews.reviews)
                  ReviewWidget(review: review),
                SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _loadPreviousPageOfReviews();
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
                      child: Text('${currentReviewPage.toString()}-${widget.totalPagesOfReviews.toString()}',
                        style: TextStyle(
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _loadNextPageOfReviews();
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
            );
          }
        },
      ),
    );
  }
}

/**
 * The widget of a review
 */
// class ReviewWidget extends StatelessWidget {
//   const ReviewWidget({
//     Key? key,
//     required this.review,
//   }) : super(key: key);
//
//   final Map<String, dynamic> review;
//
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     var style = theme.textTheme.displaySmall!.copyWith(
//       color: theme.colorScheme.secondary,
//       fontSize: 16,
//     );
//
//     return Card(
//       color: Colors.white,
//       clipBehavior: Clip.hardEdge,
//       child: Padding(
//           padding: const EdgeInsets.all(5),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 5.0),
//                 child: ClipOval(
//                   child: CircleAvatar(
//                     radius: 18.0,
//                     backgroundColor: Colors.transparent,
//                     backgroundImage: AssetImage(
//                       'assets/images/person_icon.png',
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       review['reviewerName'],
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       review['reviewDate'],
//                       style: TextStyle(
//                         fontSize: 17,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       review['reviewText'],
//                       style: TextStyle(
//                         fontSize: 16,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Wrap(
//                       spacing: 8.0, // Adjust the spacing as needed
//                       runSpacing: 8.0, // Adjust the runSpacing as needed
//                       children: review['aspectReviews'].map<Widget>((aspectReview) {
//                         return IntrinsicWidth(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: getColorFromPositivity(aspectReview['positivity']),
//                               borderRadius: BorderRadius.circular(20.0),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
//                               child: Center(
//                                 child: Text(
//                                   aspectReview['categoryName'],
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           )),
//     );
//   }
// }

class ReviewWidget extends StatefulWidget {
  final Map<String, dynamic> review;

  const ReviewWidget({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  bool _isExpanded = false;  // State to track if the text is expanded

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
      fontSize: 16,
    );

    return Card(
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: ClipOval(
                child: CircleAvatar(
                  radius: 18.0,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/images/person_icon.png'),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.review['reviewerName'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.review['reviewDate'],
                    style: TextStyle(
                      fontSize: 17,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => setState(() {
                      _isExpanded = !_isExpanded;
                    }),
                    child: Text(
                      widget.review['reviewText'],
                      style: TextStyle(fontSize: 16),
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      maxLines: _isExpanded ? null : 4,  // Toggle between showing all lines and only 4
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? "See less" : "See more",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.review['aspectReviews'].map<Widget>((aspectReview) {
                      return IntrinsicWidth(
                        child: Container(
                          decoration: BoxDecoration(
                            color: getColorFromPositivity(aspectReview['positivity']),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
                            child: Center(
                              child: Text(
                                '${aspectReview['categoryName'].replaceAll(RegExp(r'[#]'), ': ').trim()} / ${aspectReview['aspectTerm']}: ${aspectReview['opinion']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    double ratio = positivity / 1;
    return Color.lerp(lightGreen, green, positivity)!;
  }
}