import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'restaurant_details_page.dart';
import 'data_classes/restaurant.dart';
import 'data_classes/restaurant_name_info.dart';
import 'widgets/restaurant_card.dart';
import 'package:dropdown_search/dropdown_search.dart';

/**
 * Main entry point of the application
 */
void main() {
  runApp(App());
}

/**
 * Main application widget
 */
class App extends StatelessWidget {
  const App({super.key});


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'RestoReview',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen, surfaceVariant: Colors.white),
        ),
        home: HomePage(
          title: 'RestoReview',
        ),
      ),
    );
  }
}

/**
 *  Method to fetch the total number of pages of restaurants from the API
 */
Future<Map<String, dynamic>> fetchTotalPagesOfRestaurants(String city) async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8079/api/number_of_restaurants/${city}'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    // TEST DATA
    // final Map<String, dynamic> data;
    // if (city == "kl") {
    //   data = {
    //     "totalPagesOfRestaurants": 51,
    //     "restaurants": [
    //       {
    //         "restaurantId": 1,
    //         "restaurant_name": "Iketaru Restaurant",
    //       },
    //       {
    //         "restaurantId": 2,
    //         "restaurant_name": "Ishin Japanese Dining",
    //       },
    //       {
    //         "restaurantId": 3,
    //         "restaurant_name": "Chambers Grill",
    //       },
    //     ],
    //   };
    // } else if (city == "rome") {
    //   data = {
    //     "totalPagesOfRestaurants": 22,
    //     "restaurants": [
    //       {
    //         "restaurantId": 1,
    //         "restaurant_name": "Adesso Vineria-bistrot",
    //       },
    //       {
    //         "restaurantId": 2,
    //         "restaurant_name": "La Fata Ignorante - Rooftop Restaurant & Bar",
    //       },
    //       {
    //         "restaurantId": 3,
    //         "restaurant_name": "Ad Hoc Ristorante (Circo Massimo)",
    //       },
    //     ],
    //   };
    // } else {
    //   data = {
    //     "totalPagesOfRestaurants": 1000,
    //     "restaurants": [
    //       {
    //         "restaurantId": 1,
    //         "restaurant_name": "Iketaru Restaurant",
    //       },
    //       {
    //         "restaurantId": 2,
    //         "restaurant_name": "Ishin Japanese Dining",
    //       },
    //       {
    //         "restaurantId": 3,
    //         "restaurant_name": "Chambers Grill",
    //       },
    //     ],
    //   };
    // }

    final List<dynamic> restaurantInfo = data['restaurants'];
    return {
      "totalPagesOfRestaurants": data['totalPagesOfRestaurants'],
      "restaurants": restaurantInfo.map((json) => RestaurantNameInfo.fromJson(json)).toList(),
    };
    //return data.map((json) => CityInfo.fromJson(json)).toList();
  } else {
    throw Exception('Failed to retrieve total pages from API');
  }
}

/**
 * Method to fetch a list of restaurants from the API
 */
Future<List<Restaurant>> fetchRestaurants(String city, int page) async {
  final http.Response response = await http.get(Uri.parse('http://127.0.0.1:8079/api/recommended_restaurants/${city}/${page}'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    // TEST DATA
    // final Map<String, dynamic> data;
    // if (city == 'kl') {
    //   data = {
    //     'restaurants': [
    //       {
    //         'restaurantId': 1,
    //         'name': 'KL VCR Cafe',
    //         'coverImage': 'https://www.foodadvisor.my/attachments/902c3847bc35a626f8b303f489a7f8f3d82d3b8b/store/fill/800/500/c9906624687aab259426150e9cc46cf34cd2920b2d4d262be2a54d3f0c72/featured_image.jpg',
    //         'rating': 4.5,
    //         'totalReviews': 3512,
    //         'address': '31, Jln Telawi 3, Bangsar, 59100 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur',
    //         'categories': ['Cafe', 'American', 'European'],
    //       },
    //       {
    //         'restaurantId': 2,
    //         'name': 'ZEN by MEL',
    //         'coverImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmi1L80uMKiW3ABUCMC0Zf-GbP2roGGc5Fvw&usqp=CAU',
    //         'rating': 3.3,
    //         'totalReviews': 47,
    //         'address': 'F-10-01, Pusat Perdagangan Bandar, Persiaran Jalil 1, Bukit Jalil, 57000 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur',
    //         'categories': ['Fine dining restaurant'],
    //       },
    //     ],
    //   };
    // } else if (city == "rome") {
    //   data = {
    //     'restaurants': [
    //       {
    //         'restaurantId': 1,
    //         'name': 'ROME VCR Cafe',
    //         'coverImage': 'https://www.foodadvisor.my/attachments/902c3847bc35a626f8b303f489a7f8f3d82d3b8b/store/fill/800/500/c9906624687aab259426150e9cc46cf34cd2920b2d4d262be2a54d3f0c72/featured_image.jpg',
    //         'rating': 4.5,
    //         'totalReviews': 3512,
    //         'address': '31, Jln Telawi 3, Bangsar, 59100 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur',
    //         'categories': ['Cafe', 'American', 'European'],
    //       },
    //       {
    //         'restaurantId': 2,
    //         'name': 'ZEN by MEL',
    //         'coverImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmi1L80uMKiW3ABUCMC0Zf-GbP2roGGc5Fvw&usqp=CAU',
    //         'rating': 3.3,
    //         'totalReviews': 47,
    //         'address': 'F-10-01, Pusat Perdagangan Bandar, Persiaran Jalil 1, Bukit Jalil, 57000 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur',
    //         'categories': ['Fine dining restaurant'],
    //       },
    //     ],
    //   };
    // } else {
    //   data = {
    //     'restaurants': [
    //       {
    //         'restaurantId': 1,
    //         'name': 'FAILED VCR Cafe',
    //         'coverImage': 'https://www.foodadvisor.my/attachments/902c3847bc35a626f8b303f489a7f8f3d82d3b8b/store/fill/800/500/c9906624687aab259426150e9cc46cf34cd2920b2d4d262be2a54d3f0c72/featured_image.jpg',
    //         'rating': 4.5,
    //         'totalReviews': 3512,
    //         'address': '31, Jln Telawi 3, Bangsar, 59100 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur',
    //         'categories': ['Cafe', 'American', 'European'],
    //       },
    //       {
    //         'restaurantId': 2,
    //         'name': 'ZEN by MEL',
    //         'coverImage': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmi1L80uMKiW3ABUCMC0Zf-GbP2roGGc5Fvw&usqp=CAU',
    //         'rating': 3.3,
    //         'totalReviews': 47,
    //         'address': 'F-10-01, Pusat Perdagangan Bandar, Persiaran Jalil 1, Bukit Jalil, 57000 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur',
    //         'categories': ['Fine dining restaurant'],
    //       },
    //     ],
    //   };
    // }

    // final List<dynamic> restaurants = data['restaurants'];
    // return restaurants.map((json) => Restaurant.fromJson(json)).toList();
    return data.map((json) => Restaurant.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load restaurants');
  }
}

/**
 * AppState is a ChangeNotifier that holds the state of the application
 */
class AppState extends ChangeNotifier {
  String restaurantsFrom = "kl";
  int currentPageOfRestaurants = 1;
  int totalPagesOfRestaurants = 1;
  List<dynamic> restaurantsNameInfo = [];

  String getRestaurantsFrom() {
    return restaurantsFrom;
  }

  String getRestaurantsFromText() {
    if (restaurantsFrom == "kl") {
      return "Kuala Lumpur";
    } else {
      return "Rome";
    }
  }

  void updateRestaurantsFrom(String city) {
    if (restaurantsFrom != city) {
      restaurantsFrom = city;
      currentPageOfRestaurants = 1;
      notifyListeners();
    }
  }

  /**
   * Method to load the next page of restaurants
   */
  void loadNextPageOfRestaurants() {
    if (currentPageOfRestaurants < totalPagesOfRestaurants) {
      currentPageOfRestaurants++;
      notifyListeners();
    }
  }

  /**
   * Method to load the previous page of restaurants
   */
  void loadPreviousPageOfRestaurants() {
    if (currentPageOfRestaurants > 1) {
      currentPageOfRestaurants--;
      notifyListeners();
    }
  }

  /**
   * Method to update the total number of pages of restaurants
   */
  void updateTotalPagesOfRestaurants(int totalPages) {
    totalPagesOfRestaurants = totalPages;
    notifyListeners();
  }

  void updateRestaurantsNameInfo(List<dynamic> restaurantsInfo) {
    restaurantsNameInfo = restaurantsInfo;
    notifyListeners();
  }

  List<dynamic> getRestaurantsNameInfo() {
    return restaurantsNameInfo;
  }
}

/**
 * HomePage is the main page of the application
 */
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

/**
 * _HomePageState is the state of the HomePage
 */
class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: RestaurantsListingPage(),
      ),
    );
  }
}

/**
 * RestaurantsListingPage is a StatefulWidget that displays a list of restaurants
 */
class RestaurantsListingPage extends StatefulWidget {

  const RestaurantsListingPage(
      {Key? key})
      : super(key: key);

  @override
  _RestaurantsListingPageState createState() => _RestaurantsListingPageState();
}

/**
 * _RestaurantsListingPageState is the state of the RestaurantsListingPage
 */
class _RestaurantsListingPageState extends State<RestaurantsListingPage> {

  @override
  void initState() {
    super.initState();
    // fetch total pages of restaurants
    fetchTotalPagesOfRestaurants(context.read<AppState>().getRestaurantsFrom()).then((restaurantsInfo) {
      context.read<AppState>().updateTotalPagesOfRestaurants(restaurantsInfo['totalPagesOfRestaurants']);
      context.read<AppState>().updateRestaurantsNameInfo(restaurantsInfo['restaurants']);
    }).catchError((error) {
      // Handle errors if the request fails
      print('Error fetching total pages: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<AppState>();

    return LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    SizedBox(width: 6),
                    Text('Restaurants from ${appState.getRestaurantsFromText()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        overflow: TextOverflow.ellipsis,
                      ),),
                    SizedBox(width: 10),
                    DropdownSearch<dynamic>(
                      items: appState.getRestaurantsNameInfo(),
                      itemAsString: (dynamic r) => r.restaurantName,
                      onChanged: (dynamic selectedRestaurant) {
                        if (selectedRestaurant != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailsPage(
                                restaurantId: selectedRestaurant.restaurantId,
                                restaurantName: selectedRestaurant.restaurantName,
                              ),
                            ),
                          );
                        }
                      },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select a Restaurant",
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      dropdownBuilder: (context, selectedItem) {
                        return Text(selectedItem?.restaurantName ?? "Select a Restaurant");
                      },
                      popupProps: PopupProps.bottomSheet(
                        showSearchBox: true,
                        itemBuilder: (context, item, isSelected) {
                          return ListTile(
                            title: Text(item.restaurantName),
                          );
                        },
                      ),
                    ),
                    DropdownMenu(
                      width: 300,
                      onSelected: (selectedRestaurantId) {
                        if (selectedRestaurantId != null) {
                          int restaurantId = int.parse(selectedRestaurantId);
                          String restaurantName = appState.getRestaurantsNameInfo().firstWhere((restaurantInfo) => restaurantInfo.restaurantId == restaurantId).restaurantName;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailsPage(
                                restaurantId: restaurantId,
                                restaurantName: restaurantName,
                              ),
                            ),
                          );
                        }
                      },
                      dropdownMenuEntries: appState.getRestaurantsNameInfo()
                          .map<DropdownMenuEntry<String>>((restaurantInfo) => DropdownMenuEntry(
                        value: restaurantInfo.restaurantId.toString(),
                        label: restaurantInfo.restaurantName,
                      ))
                          .toList(),
                    ),
                    Spacer(),
                    DropdownMenu(
                      initialSelection: appState.getRestaurantsFrom(),
                      onSelected: (selectedCity) async {
                        if (selectedCity != null && selectedCity != appState.getRestaurantsFrom()) {
                          appState.updateRestaurantsFrom(selectedCity);
                          Map<String, dynamic> restaurantsInfo = await fetchTotalPagesOfRestaurants(selectedCity);
                          int totalPages = restaurantsInfo['totalPagesOfRestaurants'];
                          appState.updateTotalPagesOfRestaurants(totalPages);
                          appState.updateRestaurantsNameInfo(restaurantsInfo['restaurants']);
                        }
                      },
                      dropdownMenuEntries: <DropdownMenuEntry<String>>[
                        DropdownMenuEntry(value: "kl", label: "Kuala Lumpur"),
                        DropdownMenuEntry(value: "rome", label: "Rome")
                      ],
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        appState.loadPreviousPageOfRestaurants();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text('${appState.currentPageOfRestaurants.toString()}-${appState.totalPagesOfRestaurants.toString()}',
                      style: TextStyle(
                        fontSize: 25,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        appState.loadNextPageOfRestaurants();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, right: 16),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 25.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Restaurant>>(
                  future: fetchRestaurants(appState.getRestaurantsFrom(), appState.currentPageOfRestaurants),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display a loading indicator while the data is being fetched
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.secondary,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      // Display an error message if the request fails
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // Display a message if no restaurants are available
                      return Center(
                        child: Text('No restaurants available.'),
                      );
                    } else {
                      final List<Restaurant>? restaurants = snapshot.data;

                      return GridView(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          childAspectRatio: 400 / 420,
                        ),
                        children: [
                          for (var restaurant in restaurants!)
                            RestaurantCard(
                                restaurant: restaurant,
                                onCardTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RestaurantDetailsPage(
                                        restaurantId: restaurant.restaurantId,
                                        restaurantName: restaurant.name,
                                      ),
                                    ),
                                  );
                                }
                            ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          );
        }
    );
  }
}
