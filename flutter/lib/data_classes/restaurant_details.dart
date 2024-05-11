/**
 * The following is the data class for the detailed information of a restaurant
 */
class RestaurantDetails {
  final int restaurantId;
  final String name;
  final String coverImage;
  final String status;
  final List<String> operatingHours;
  final double rating;
  final int totalReviews;
  final int priceRange;
  final String fullAddress;
  final List<String> categories;
  final String websiteUrl;
  final String phoneNumber;
  final List<Map<String, dynamic>> aspectsSummary;
  final int totalPagesOfReviews;
  final int totalPagesOfRecommendedRestaurants;


  RestaurantDetails({
    required this.restaurantId,
    required this.name,
    required this.coverImage,
    required this.status,
    required this.operatingHours,
    required this.rating,
    required this.totalReviews,
    required this.priceRange,
    required this.fullAddress,
    required this.categories,
    required this.websiteUrl,
    required this.phoneNumber,
    required this.aspectsSummary,
    required this.totalPagesOfReviews,
    required this.totalPagesOfRecommendedRestaurants,
  });

  factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
    return RestaurantDetails(
      restaurantId: json['restaurantId'],
      name: json['name'],
      coverImage: json['coverImage'],
      status: json['status'],
      operatingHours: json['operatingHours'],
      rating: json['rating'],
      totalReviews: json['totalReviews'],
      priceRange: json['priceRange'],
      fullAddress: json['fullAddress'],
      categories: json['categories'],
      websiteUrl: json['websiteUrl'],
      phoneNumber: json['phoneNumber'],
      aspectsSummary: json['aspectsSummary'],
      totalPagesOfReviews: json['totalPagesOfReviews'],
      totalPagesOfRecommendedRestaurants: json['totalPagesOfRecommendedRestaurants'],
    );
  }
}