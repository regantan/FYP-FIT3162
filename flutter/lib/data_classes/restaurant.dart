/**
 * The following is the data class for a restaurant containing its common information
 */
class Restaurant {
  final int restaurantId;
  final String name;
  final String coverImage;
  final double rating;
  final int totalReviews;
  final List<String> categories;
  final String url;

  Restaurant({
    required this.restaurantId,
    required this.name,
    required this.coverImage,
    required this.rating,
    required this.totalReviews,
    required this.categories,
    required this.url,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantId: json['id'],
      name: json['restaurant_name'],
      coverImage: 'https://media.timeout.com/images/101591411/image.jpg',
      rating: json['star_rating'],
      totalReviews: json['no_reviews'],
      categories: ['japan', 'korea'],
      url: json['trip_advisor_url'],
    );
  }
}