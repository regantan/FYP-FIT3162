import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'restaurant_details_page.dart';
import 'data_classes/restaurant.dart';
import 'widgets/restaurant_card.dart';

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
        debugShowCheckedModeBanner: false,
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

    return {
      "totalPagesOfRestaurants": data['totalPagesOfRestaurants'],
    };
  } else {
    throw Exception('Failed to retrieve total pages from API');
  }
}

/**
 * Method to fetch a list of restaurants from the API
 */
Future<List<Restaurant>> fetchRestaurants(String city, int page, String searchTerm) async {
  http.Response response;
  if (searchTerm.isEmpty) {
    response = await http.get(Uri.parse('http://127.0.0.1:8079/api/recommended_restaurants/${city}/${page}'));
  }
  else {
    response = await http.get(Uri.parse('http://127.0.0.1:8079/api/search/${searchTerm}/${city}/${page}'));
  }

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);

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
  String searchTerm = "";

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

  void updateSearch(String term) async {
    searchTerm = term;
    currentPageOfRestaurants = 1;
    http.Response response;
    if (term.isEmpty) {
      response = await http.get(Uri.parse('http://127.0.0.1:8079/api/number_of_restaurants/${restaurantsFrom}'));
    } else {
      response = await http.get(Uri.parse('http://127.0.0.1:8079/api/search_page/${term}/${restaurantsFrom}'));
    }
    if (response.statusCode == 200) {
      totalPagesOfRestaurants = json.decode(response.body)['totalPagesOfRestaurants'];
    }
    notifyListeners();
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
                    Container(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search Restaurant",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String value) => appState.updateSearch(value),
                      ),
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
                          appState.updateSearch(appState.searchTerm);
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
                  future: fetchRestaurants(appState.getRestaurantsFrom(), appState.currentPageOfRestaurants, appState.searchTerm),
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
                          childAspectRatio: 400 / 220,
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
