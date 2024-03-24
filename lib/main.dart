import 'package:flutter/material.dart';
import 'api_caller.dart';
import 'dialog_utils.dart';
import 'my_list_tile.dart';
import 'my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Define a variable to store the data from the API
  List<dynamic> _wineList = [];

  @override
  void initState() {
    super.initState();
    // Call the method to fetch data from the API
    fetchData();
  }

  // Create a method to fetch data from the API
  Future<void> fetchData() async {
    try {
      // Perform GET request using Dio
      Response response = await Dio().get('https://api.sampleapis.com/wines/reds');
      // Extract the data from the response
      setState(() {
        _wineList = response.data;
      });
    } catch (error) {
      // Handle any errors that occur during the request
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Red Wines'),
        ),
        body: Center(
          child: _wineList.isEmpty
              ? CircularProgressIndicator() // Show loading indicator while data is being fetched
              : ListView.builder(
                  itemCount: _wineList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_wineList[index]['wine']),
                      subtitle: Text(_wineList[index]['winery']),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(_wineList[index]['image']),
                      ),
                    );
                  },
                ), // Display the fetched data
        ),
      ),
    );
  }
}