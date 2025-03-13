import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefund/Chart.dart';
import 'package:wefund/History.dart';
import 'package:wefund/Positions.dart';
import 'package:wefund/SettingsPage.dart';
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/Watchlist.dart';

class BottomNavigationBarWidget extends StatefulWidget {


  const BottomNavigationBarWidget({super.key,});

  @override
  _BottomNavigationBarWidgetState createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

    List<Widget> _pages = [
      Watchlist(),
      Chart(),
      Positions(),
      History(),
      SettingsPage(),
    ];

    return Scaffold(
            backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,

      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
     backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        unselectedItemColor: Colors.grey ,
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Chart'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Positions'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
