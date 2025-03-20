import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';

class Pamm {
  String traderName;
  String traderType;

  Pamm({required this.traderName, required this.traderType});

  factory Pamm.fromJson(Map<String, dynamic> json) {
    return Pamm(
      traderName: json['Trader Name'] ?? 'N/A',
      traderType: json['Trader Type'] ?? 'N/A',
    );
  }
}

class PAMMPage extends StatefulWidget {
  @override
  _PAMMPageState createState() => _PAMMPageState();
}

class _PAMMPageState extends State<PAMMPage> {
  List<Pamm> tradingSignals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPAMMUsers();
  }

  Future<void> fetchPAMMUsers() async {
    const String apiUrl = "https://wefundclient.com/Crm/Crm/pammtrading_api.php";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          tradingSignals = jsonData.map((item) => Pamm.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PAMM",
          style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      ),
      body: Column(
        children: [
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelStyle: TextStyle(fontSize: 16.px, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontSize: 16.px, fontWeight: FontWeight.normal),
                  tabs: [
                    Tab(text: "PAMM USER LIST"),
                    Tab(text: "FOLLOWING PAMM LIST"),
                  ],
                ),
                Container(
                  color: Colors.transparent,
                  height: 50.h,
                  child: TabBarView(
                    children: [
                      _buildTradingSignals(),
                      Center(
                        child: Text(
                          "No User Found",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingSignals() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (tradingSignals.isEmpty) {
      return Center(
        child: Text(
          "No User Found",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
        ),
      );
    }

    return ListView.builder(
      itemCount: tradingSignals.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              tradingSignals[index].traderName,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              tradingSignals[index].traderType,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
            ),
          ),
        );
      },
    );
  }
}
