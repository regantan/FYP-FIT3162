import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp_fit3161_team8_web_app/data_classes/restaurant.dart';


class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onCardTap,
  }) : super(key: key);

  final Restaurant restaurant;
  final VoidCallback onCardTap;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
      fontSize: 16,
    );

    return InkWell(
      onTap: onCardTap,
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.hardEdge,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 5,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0), // Adjust the radius to control the roundness of corners
                        child: CachedNetworkImage(
                          imageUrl: restaurant.coverImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/image_placeholder.jpg',
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Container(
                              child: Icon(
                                Icons.error,
                                size: 50,
                              )
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(height: 50),
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 8,
                            fit: FlexFit.loose,
                            child: Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: restaurant.rating.toDouble(),
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
                                  ignoreGestures: true, onRatingUpdate: (double value) {  }, // Makes the rating bar read-only
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${restaurant.rating.toString()} (${NumberFormat.compact().format(restaurant.totalReviews).toString()} reviews)',
                        style: style,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        restaurant.categories.join(', '),
                        style: style,
                      ),
                      if (restaurant.similarityScore != null) ...[
                        SizedBox(height: 5),
                        Text(
                          'Similarity Score: ${restaurant.similarityScore!.toStringAsFixed(2)}',
                          style: style,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}