import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';
class Positions extends StatefulWidget {
  const Positions({super.key});

  @override
  State<Positions> createState() => _PositionsState();
}

class _PositionsState extends State<Positions> {
  @override
  Widget build(BuildContext context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
            "Positions",
            style: TextStyle(  fontSize: 22.px,
                fontWeight: FontWeight.w700,),
          )),
          backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, iconTheme: IconThemeData(
    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),),
        body: Center(
          child: Text("Positions Page",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w800)),
        ));
  }
}
