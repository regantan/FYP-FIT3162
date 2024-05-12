/**
 * The following is the data class for a restaurant containing its common information
 */
class Restaurant {
  final int restaurantId;
  final String name;
  final String coverImage;
  final double rating;
  final int totalReviews;
  final String address;
  final List<String> categories;

  Restaurant({
    required this.restaurantId,
    required this.name,
    required this.coverImage,
    required this.rating,
    required this.totalReviews,
    required this.address,
    required this.categories,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantId: json['restaurantId'],
      name: json['name'],
      coverImage: json['coverImage'],
      rating: json['rating'],
      totalReviews: json['totalReviews'],
      address: json['address'],
      categories: json['categories'],
    );
  }
}