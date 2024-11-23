import 'package:flutter/material.dart';
import 'package:heritage_soft/pages/other/gym_data_report_page.dart';

class DataReportPage extends StatefulWidget {
  const DataReportPage({super.key});

  @override
  State<DataReportPage> createState() => _DataReportPageState();
}

class _DataReportPageState extends State<DataReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 2, 20, 35),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 2, 20, 35),
        // bottom: ,
        title: Text('Office Data Report'),
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // gym
            tile('Gym Data', GymDataReportPage()),

            // physio
            // tile('Physio Data', GymDataReportPage()),
          ],
        ),
      ),
    );
  }

  // tile
  Widget tile(String title, Widget page) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
        child: Container(
          width: 200,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.49),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.data_exploration, color: Colors.white, size: 70),
                SizedBox(height: 15),
                // title
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
