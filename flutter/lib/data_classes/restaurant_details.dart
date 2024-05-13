/**
 * The following is the data class for the detailed information of a restaurant
 */
class RestaurantDetails {
  final int restaurantId;
  final String name;
  final String coverImage;
  final double rating;
  final int totalReviews;
  final String location;
  final List<dynamic> categories;
  final String websiteUrl;
  final List<dynamic> aspectsSummary;
  final List<dynamic> averageScoresByYear;
  final int totalPagesOfReviews;
  final int totalPagesOfRecommendedRestaurants;

  RestaurantDetails({
    required this.restaurantId,
    required this.name,
    required this.coverImage,
    required this.rating,
    required this.totalReviews,
    required this.location,
    required this.categories,
    required this.websiteUrl,
    required this.aspectsSummary,
    required this.averageScoresByYear,
    required this.totalPagesOfReviews,
    required this.totalPagesOfRecommendedRestaurants,
  });

  factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
    return RestaurantDetails(
      restaurantId: json['id'],
      name: json['restaurant_name'],
      coverImage: 'https://media.timeout.com/images/101591411/image.jpg',
      rating: json['star_rating'],
      totalReviews: json['no_reviews'],
      location: json['location'].toLowerCase() == 'kl' ? "Kuala Lumpur" : json['location'],
      categories: json['cuisine'],
      websiteUrl: json['trip_advisor_url'],
      aspectsSummary: json['aspectsSummary'],
      averageScoresByYear: json['average_scores_by_year'],
      totalPagesOfReviews: json['totalPagesOfReviews'],
      totalPagesOfRecommendedRestaurants: 12,
    );
  }
}