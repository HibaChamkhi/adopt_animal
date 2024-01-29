import 'package:adopt_animal/features/profile/presentation/pages/settings.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = NotchBottomBarController(index: 0);
  final _pageController = PageController(initialPage: 0);
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  final List<Widget> bottomBarPages = [
    InkWell(onTap: (){

    }
  ,child: const Text("page1",style: TextStyle(color: Colors.blue),)),
    const Text("page2"),
    const Text("page3"),
    const SettingsPage()  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          bottomBarItems: const [
            BottomBarItem(
              inActiveItem: Icon(
                Icons.home_filled,
                color:careysPink,
              ),
              activeItem: Icon(
                Icons.home_filled,
                color: careysPink,
              ),
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.heart_broken,
                color: careysPink,
              ),
              activeItem: Icon(
                Icons.heart_broken,
                color: careysPink,
              ),
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.chat_sharp,
                color: careysPink,
              ),
              activeItem: Icon(
                Icons.chat_sharp,
                color: careysPink,
              ),
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.settings,
                color: careysPink,
              ),
              activeItem: Icon(
                Icons.settings,
                color: careysPink,
              ),
            ),
          ],
        onTap: (int index) {
          print('current selected index $index');
          _pageController.jumpToPage(index);
        },),
      body:  PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
    );
  }
}
