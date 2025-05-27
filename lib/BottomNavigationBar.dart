import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefund/Chart.dart';
import 'package:wefund/History.dart';
import 'package:wefund/Positions.dart';
import 'package:wefund/SettingsPage.dart';
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/Watchlist.dart';

class BottomNavigationBarWidget extends StatefulWidget {

 final String jwt;
  final int initialIndex;
  const BottomNavigationBarWidget({
    Key? key,
    required this.jwt,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _BottomNavigationBarWidgetState createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  late int _currentIndex;
  
  @override
   void initState() {
     super.initState();
     // start on whatever tab the parent told us
     _currentIndex = widget.initialIndex;
   }

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

    final _pages = [
      Watchlist(),
      Chart(),
      PositionsPage(jwt: widget.jwt),
      HistoryPage(jwt: widget.jwt),
      
      SettingsPage(),
    ];

    return Scaffold(
            backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,

      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            themeProvider.isDarkMode ? Colors.black : Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Chart'),
          BottomNavigationBarItem(icon: Icon(Icons.business_center), label: 'Positions'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
