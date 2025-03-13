import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';
class Watchlist extends StatefulWidget {
  const Watchlist({super.key});

  @override
  State<Watchlist> createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> {
  @override
  Widget build(BuildContext context) {    
     final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Watchlist",
          style: TextStyle(  fontSize: 22.px,
                fontWeight: FontWeight.w700,),
        )),
 backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, iconTheme: IconThemeData(
    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
  ),
      ),
      body: Center(
          child: Text(
        "Watchlist Page",
        style: TextStyle(
            fontSize: 30,
            color: Colors.blueAccent,
            fontWeight: FontWeight.w800),
      )),
    );
  }
}
