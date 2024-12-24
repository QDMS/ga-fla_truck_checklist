import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:truckchecklist/global.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:truckchecklist/views/nav-screens/profile_screen.dart';
import 'package:truckchecklist/views/nav-screens/truck_check_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.truck,
    FontAwesomeIcons.userLarge,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "SweepTime",
          style: TextStyle(
            fontFamily: 'NexaBold',
            color: primary,
            fontSize: 45,
          ),
        ),
        toolbarHeight: 50,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [TruckCheckListScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(navigationIcons.length, (i) {
              return Expanded(
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  onTap: () {
                    setState(() {
                      currentIndex = i;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    color: primary,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            navigationIcons[i],
                            color:
                                i == currentIndex ? Colors.black : Colors.white,
                            size: i == currentIndex ? 30 : 20,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            height: 3,
                            width: 24,
                            decoration: BoxDecoration(
                              color: i == currentIndex ? Colors.black : primary,
                              borderRadius: BorderRadius.circular(40),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
