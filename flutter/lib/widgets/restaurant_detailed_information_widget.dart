import 'package:flutter/material.dart';
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
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
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
    return widget.restaurantDetails.averageScoresByQuarter
        .map((data) => DropdownMenuItem<String>(
      value: data['aspect_name'],
      child: Text(data['aspect_name'].replaceAll('#', ': ')),
    ))
        .toList();
  }

  void updateChartData() {
    var aspectData = widget.restaurantDetails.averageScoresByQuarter
        .firstWhere((data) => data['aspect_name'] == selectedAspect, orElse: () => null);

    if (aspectData != null) {
      lineChartData = List.generate(
        aspectData['quarters'].length,
            (index) => FlSpot(
          aspectData['quarters'][index].toDouble(),
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
            child: Text('Quarter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 0.5,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('${value.toDouble()}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                          ),
                        );
                      },
                    )),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 0.5,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final quarter = (value % 1) * 4;
                        final year = value.toInt();
                        String quarterLabel;
                        switch (quarter.toInt()) {
                          case 0:
                            quarterLabel = 'Q1';
                            break;
                          case 1:
                            quarterLabel = 'Q2';
                            break;
                          case 2:
                            quarterLabel = 'Q3';
                            break;
                          case 3:
                            quarterLabel = 'Q4';
                            break;
                          default:
                            quarterLabel = '';
                        }
                        return Transform.rotate(
                          angle: -0.7, // Rotate the text
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              '$year $quarterLabel',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12, // You can adjust the font size as well
                              ),
                            ),
                          ),
                        );
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
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final quarter = (spot.x % 1) * 4;
                      final year = spot.x.toInt();
                      String quarterLabel;
                      switch (quarter.toInt()) {
                        case 0:
                          quarterLabel = 'Q1';
                          break;
                        case 1:
                          quarterLabel = 'Q2';
                          break;
                        case 2:
                          quarterLabel = 'Q3';
                          break;
                        case 3:
                          quarterLabel = 'Q4';
                          break;
                        default:
                          quarterLabel = '';
                      }
                      return LineTooltipItem(
                        'Year: $year\nQuarter: $quarterLabel\nPolarity: ${spot.y}',
                        TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                touchCallback: (FlTouchEvent touchEvent, LineTouchResponse? touchResponse) {},
                mouseCursorResolver: (FlTouchEvent touchEvent, LineTouchResponse? response) {
                  return response == null || response.lineBarSpots == null
                      ? MouseCursor.defer
                      : SystemMouseCursors.click;
                },
                getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
                  return indicators.map((int index) {
                    final line = FlLine(color: Colors.black, strokeWidth: 2);
                    return TouchedSpotIndicatorData(line, FlDotData(show: true));
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}