import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/SettingsPage.dart';
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/copytreding.dart';
import 'package:wefund/pamm.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedTab = "Copy Trading"; // Default selected tab

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"  ,style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), // iOS-style back arrow
            onPressed: () {
              Navigator.pop(context);
            },
          ),
            backgroundColor:
              themeProvider.isDarkMode ? Colors.black : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome WeFund",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildAccountStatus(),
            SizedBox(height: 0.5.h),

            _buildInfoCard("User Name", "46RALNJKVB", isBold: true),
            _buildInfoCard("Balance", "\$ 0.00"),
            _buildInfoCard("Free Margin", "\$ 0.00"),

            SizedBox(height: 1.h),

            // Trading Tabs
            _buildTradingTabs(context),

            SizedBox(height: 2.h),

            Text(
              "No Users Found",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 1.h),

Align(  alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  
                },      
                      

                child: Text(
                  "View All",
                  style: TextStyle(color: Colors.white),
                ),

              ),
              
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatus() {
    return 
    Container(
      height: 8.h,width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Account Status", style: TextStyle(fontSize: 18.sp)),
          SizedBox(height: 1.h),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //   decoration: BoxDecoration(
          //     color: Colors.blue,
          //     borderRadius: BorderRadius.circular(10.sp),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.cancel, color: Colors.red, size: 17.sp),
          //       SizedBox(width: 2.w),
          //       Text("Account Not Verified",
          //           style: TextStyle(color: Colors.white,fontSize: 16.sp,fontWeight: FontWeight.bold)),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {bool isBold = false}) {
    return Container(
        height: 10.h,width: double.infinity,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w500)),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingTabs(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabButton(context, "Copy Trading", CopyTradingPage()),
          _buildTabButton(context, "Client Portal", ClientPortalPage()),
          _buildTabButton(context, "PAMM", PAMMPage()),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String title, Widget screen) {
    bool isActive = selectedTab == title; // Check if this tab is active

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = title; // Update selected tab
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[100] : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.orange : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isActive ? Colors.orange : Colors.black,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
