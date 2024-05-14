/**
 * The following is the data class for a restaurant containing its common information
 */
class RestaurantNameInfo {
  final int restaurantId;
  final String restaurantName;

  RestaurantNameInfo({
    required this.restaurantId,
    required this.restaurantName,
  });

  factory RestaurantNameInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantNameInfo(
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurant_name']
    );
  }

}