import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "History",
          style: TextStyle(  fontSize: 22.px,
                fontWeight: FontWeight.w700,),
        )),
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, 
      iconTheme: IconThemeData(
    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
  ),
      ),
      body: Center(
          child: Text("History Page",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w800))),
    );
  }
}
