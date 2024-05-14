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
  final double? similarityScore;

  Restaurant({
    required this.restaurantId,
    required this.name,
    required this.coverImage,
    required this.rating,
    required this.totalReviews,
    required this.categories,
    required this.url,
    this.similarityScore,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantId: json['id'],
      name: json['restaurant_name'],
      coverImage: 'https://media.timeout.com/images/101591411/image.jpg',
      rating: json['star_rating'],
      totalReviews: json['no_reviews'],
      categories: ['japan', 'seafood'],
      url: json['trip_advisor_url'],
      similarityScore: (json['similarity_score'] as num?)?.toDouble(),
    );
  }
}