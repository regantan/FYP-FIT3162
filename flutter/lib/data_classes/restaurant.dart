/**
 * The following is the data class for a restaurant containing its common information
 */
class Restaurant {
  final int restaurantId;
  final String name;
  final String coverImage;
  final double rating;
  final int totalReviews;
  final List<dynamic> categories;
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
      categories: json['cuisine']
          .substring(1, json['cuisine'].length - 1) // Remove the surrounding brackets
          .split(',') // Split the string by commas
          .map((item) => item.trim())
          .map((item) => item.substring(1, item.length - 1))
          .toList(),
      url: json['trip_advisor_url'],
    );
  }
}