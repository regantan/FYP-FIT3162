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

  bool _isOperatingHoursExpanded = false;
  List<String> dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                  widget.restaurantDetails.fullAddress,
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
          SizedBox(height: 5),
          Text('Polarity Value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 300,
              child: AspectsOverTimeLineChart(),
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
//
// class AspectsOverTimeLineChart extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return LineChart(
//       LineChartData(
//         minY: -1, // Minimum value of Y-axis
//         maxY: 1,  // Maximum value of Y-axisX: 2016,
//         gridData: FlGridData(show: true),
//         titlesData: FlTitlesData(
//           show: true,
//           leftTitles: AxisTitles(sideTitles: SideTitles(
//             showTitles: true,  // Ensure this is true to show titles
//             reservedSize: 30,  // Adjust size to make sure titles fit without being cut off
//             interval: 1,
//             getTitlesWidget: (double value, TitleMeta meta) {
//               return Text('${value.toInt()}',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 14,
//                   ));
//             },
//           )),
//           bottomTitles: AxisTitles(sideTitles: SideTitles(
//             showTitles: true,  // Ensure this is true to show titles
//             reservedSize: 40,  // Adjust size to make sure titles fit without being cut off
//             interval: 1,
//             getTitlesWidget: (double value, TitleMeta meta) {
//               return Text('${value.toInt()}',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 14,
//                   ));
//             },
//           )),
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles:AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: true),
//         lineBarsData: [
//           LineChartBarData(
//             spots: [FlSpot(2020, -1), FlSpot(2021, 0.2)], // Line 1 with negative value
//             isCurved: false,
//             color: Colors.red,
//             barWidth: 2,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: true),
//           ),
//           LineChartBarData(
//             spots: [FlSpot(2019, 1), FlSpot(2023, 0)], // Line 2 with negative value
//             isCurved: false,
//             color: Colors.blue,
//             barWidth: 2,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: true),
//           ),
//           LineChartBarData(
//             spots: [FlSpot(2020, 0.5), FlSpot(2022, -1)], // Line 3 with negative value
//             isCurved: false,
//             color: Colors.green,
//             barWidth: 2,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: true),
//           ),
//           LineChartBarData(
//             spots: [FlSpot(2018, -1), FlSpot(2019, 0.7)], // Line 4 with negative value
//             isCurved: false,
//             color: Colors.orange,
//             barWidth: 2,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: true),
//           ),
//         ],
//       ),
//     );
//   }
// }

class AspectsOverTimeLineChart extends StatelessWidget {
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
                  spots: [FlSpot(2020, -1), FlSpot(2021, 0.2)], // Line 1 with negative value
                  isCurved: false,
                  color: Colors.red,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: [FlSpot(2019, 1), FlSpot(2023, 0)], // Line 2 with negative value
                  isCurved: false,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: [FlSpot(2020, 0.5), FlSpot(2022, -1)], // Line 3 with negative value
                  isCurved: false,
                  color: Colors.green,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: [FlSpot(2018, -1), FlSpot(2019, 0.7)], // Line 4 with negative value
                  isCurved: false,
                  color: Colors.orange,
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
