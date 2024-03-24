import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'api_caller.dart';
import 'dialog_utils.dart';
import 'my_list_tile.dart';
import 'my_text_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebTypesScreen(),
    );
  }
}

class WebTypesScreen extends StatefulWidget {
  @override
  _WebTypesScreenState createState() => _WebTypesScreenState();
}

class _WebTypesScreenState extends State<WebTypesScreen> {
  // Define a variable to store the data from the API
  List<dynamic> _webTypes = [];
  int _selectedIndex = -1; // Index of the selected item
  List<String> _urls = [];
  List<Map<String, String>> _submittedData = [];

  // Controllers for text fields
  TextEditingController _urlTextEditingController = TextEditingController();
  TextEditingController _detailsTextEditingController = TextEditingController();

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
      Response response = await Dio().get(
          'https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/web_types');
      // Extract the data from the response
      setState(() {
        _webTypes = response.data;
        // Initialize URLs list
        _urls = List.generate(_webTypes.length, (index) => '');
      });
    } catch (error) {
      // Handle any errors that occur during the request
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Webby Fondues',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 80, 154, 82),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(24.0),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'ระบบรายงานเว็บไซต์',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                MyTextField(
                  controller: _urlTextEditingController,
                  hintText: 'Enter URL*',
                ),
                MyTextField(
                  controller: _detailsTextEditingController,
                  hintText: 'Enter details',
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: _webTypes.isEmpty
                  ? CircularProgressIndicator()
                  : ListView.builder(
                      itemCount: _webTypes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(_webTypes[index]['image']),
                          ),
                          title: Text(_webTypes[index]['title']),
                          subtitle: Text(_webTypes[index]['subtitle']),
                          trailing: Radio(
                            value: index,
                            groupValue: _selectedIndex,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedIndex = value!;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () {
                if (_selectedIndex != -1) {
                  String selectedTitle = _webTypes[_selectedIndex]['title'];
                  String selectedURL = _urlTextEditingController.text;
                  String selectedDetails = _detailsTextEditingController.text;
                  // Check if URL and web type are filled
                  if (selectedURL.isNotEmpty && selectedTitle.isNotEmpty) {
                    // URL and web type are filled, proceed with sending data
                    // Perform some action with the collected data, such as sending it to a server
                    // Store submitted data
                    _submittedData.add({
                      'Title': selectedTitle,
                      'URL': selectedURL,
                      'Details': selectedDetails,
                    });
                    // Show success dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Success'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ขอบคุณสำหรับการแจ้งข้อมูล\n\nสถิติการรายงาน\n==========',
                              ),
                              SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _webTypes.map((webType) {
                                  final title = webType['title'];
                                  final count = _submittedData.where((data) => data['Title'] == title).length;
                                  return Text('$title: $count');
                                }).toList(),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _selectedIndex = -1; // Clear selection
                                  _urlTextEditingController
                                      .clear(); // Clear URL text field
                                  _detailsTextEditingController
                                      .clear(); // Clear details text field
                                });
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // URL or web type is empty, show an error message
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content:
                              Text('Please fill in both URL and web type.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  // If no web type is selected, show an error message
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('ต้องกรอก URL และเลือกประเภทเว็บ'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              icon: Icon(Icons.send),
              label: Text('ส่งข้อมูล'),
            ),
          ),
        ],
      ),
    );
  }
}
