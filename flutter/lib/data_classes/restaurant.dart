/**
 * The following is the data class for a restaurant containing its common information
 */
class Restaurant {
  final int restaurantId;
  final String name;
  final String coverImage;
  final String status;
  final List<String> operatingHours;
  final double rating;
  final int totalReviews;
  final int priceRange;
  final String address;
  final List<String> categories;

  Restaurant({
    required this.restaurantId,
    required this.name,
    required this.coverImage,
    required this.status,
    required this.operatingHours,
    required this.rating,
    required this.totalReviews,
    required this.priceRange,
    required this.address,
    required this.categories,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantId: json['restaurantId'],
      name: json['name'],
      coverImage: json['coverImage'],
      status: json['status'],
      operatingHours: json['operatingHours'],
      rating: json['rating'],
      totalReviews: json['totalReviews'],
      priceRange: json['priceRange'],
      address: json['address'],
      categories: json['categories'],
    );
  }
}