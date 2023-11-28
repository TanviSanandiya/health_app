import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity',
      home: DataVisualization(),
    );
  }
}

class DataVisualization extends StatefulWidget {
  @override
  _DataVisualizationState createState() => _DataVisualizationState();
}

class _DataVisualizationState extends State<DataVisualization> {
  List<dynamic> data = [];

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/data'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body)['data'];
      setState(() {
        data = jsonData;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  double calculateTotal(List<dynamic> data, String field) {
    double total = 0.0;
    for (var entry in data) {
      try {
        total += entry[field].toDouble();
      } catch (e) {
        print('Error calculating total $field: $e');
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Total distance walked this week (km): ${calculateTotal(data, 'distance').toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 18, 204, 233)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Total calories burnt this week (kcal): ${calculateTotal(data, 'calories').toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 18, 204, 233)),
            ),
          ),
          SizedBox(height: 100),
          Expanded(
            child: ChartWidget(data: data),
          ),
          
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              'Steps this week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 18, 204, 233)),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartWidget extends StatelessWidget {
  final List<dynamic> data;

  ChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    List<String> dayLabels = [];

    // Calculating the starting index based on the data length and the last seven days
    int startIndex = data.length - 7;
    if (startIndex < 0) {
      startIndex = 0;
    }

    for (int i = startIndex; i < data.length; i++) {
      double value = 0.0;

      try {
        value = data[i]['steps'].toDouble();
        dayLabels.add('Day${i - startIndex + 1}');
      } catch (e) {
        print('Error parsing data at index $i: $e');
        continue;
      }

      barGroups.add(
        BarChartGroupData(
          x: i.toDouble().toInt(),
          barRods: [
            BarChartRodData(
              y: value,
              width: 30,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 100, 
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              leftTitles: SideTitles(showTitles: false),
              bottomTitles: SideTitles(showTitles: false),
              rightTitles: SideTitles(showTitles: false),
              topTitles: SideTitles(showTitles: false),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d), width: 2),
            ),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
}
