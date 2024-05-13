import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:fyp_fit3161_team8_web_app/data_classes/restaurant_details.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailedInformationWidget extends StatefulWidget {

  final RestaurantDetails restaurantDetails;

  const RestaurantDetailedInformationWidget({Key? key,
    required this.restaurantDetails})
      : super(key: key);

  @override
  _RestaurantDetailedInformationWidgetState createState() => _RestaurantDetailedInformationWidgetState();
}

class _RestaurantDetailedInformationWidgetState extends State<RestaurantDetailedInformationWidget> {
  String? selectedAspect;
  late List<DropdownMenuItem<String>> dropdownMenuItems;
  List<FlSpot> lineChartData = [];

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    dropdownMenuItems = getDropdownMenuItems();
    selectedAspect = dropdownMenuItems.first.value; // Set the default value to the first item
    updateChartData();
  }

  List<DropdownMenuItem<String>> getDropdownMenuItems() {
    return widget.restaurantDetails.averageScoresByYear
        .map((data) => DropdownMenuItem<String>(
      value: data['aspect_name'],
      child: Text(data['aspect_name'].replaceAll('#', ': ')),
    )).toList();
  }

  void updateChartData() {
    var aspectData = widget.restaurantDetails.averageScoresByYear
        .firstWhere((data) => data['aspect_name'] == selectedAspect, orElse: () => null);

    if (aspectData != null) {
      lineChartData = List.generate(
        aspectData['years'].length,
            (index) => FlSpot(
          aspectData['years'][index].toDouble(),
          aspectData['average_polarity'][index],
        ),
      );
    } else {
      lineChartData = []; // Ensure it's not null if no data matches
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 24.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.restaurantDetails.location,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Icon(
                  Icons.restaurant_menu_outlined,
                  size: 24.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.restaurantDetails.categories.join(', '),
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Icon(
                  Icons.public_outlined,
                  size: 24.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _launchURL(widget.restaurantDetails.websiteUrl),
                  child: Text(
                    widget.restaurantDetails.websiteUrl,
                    style: TextStyle(
                      color: Colors.blue,  // Make it look like a link
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Aspects Over Time',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: DropdownButton<String>(
              value: selectedAspect,
              onChanged: (newValue) {
                setState(() {
                  selectedAspect = newValue;
                  updateChartData();
                });
              },
              items: dropdownMenuItems,
            ),
          ),
          SizedBox(height: 5),
          Text('Polarity Value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 300,
              child: AspectsOverTimeLineChart(dataSpots: lineChartData),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Year', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }
}

class AspectsOverTimeLineChart extends StatelessWidget {
  final List<FlSpot> dataSpots;

  const AspectsOverTimeLineChart({Key? key, required this.dataSpots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Expanded(
          child: LineChart(
            LineChartData(
              minY: -1,
              maxY: 1,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  interval: 1,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text('${value.toInt()}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ));
                  },
                )),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  interval: 1,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text('${value.toInt()}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ));
                  },
                )),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                    spots: dataSpots,
                    isCurved: false,
                    color: Colors.black,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
