import 'package:adopt_animal/features/profile/presentation/pages/settings.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'home_page.dart';

class BottomNavBarPage extends StatefulWidget {
  const BottomNavBarPage({super.key});

  @override
  State<BottomNavBarPage> createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends State<BottomNavBarPage> {
  final _controller = NotchBottomBarController(index: 0);
  final _pageController = PageController(initialPage: 0);
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  final List<Widget> bottomBarPages = [
    HomePage(),
    const Center(child: Text("Coming soon..")),
    const Center(child: Text("Coming soon..")),
    const SettingsPage()  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          bottomBarItems:  [
            const BottomBarItem(
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
              inActiveItem: Image.asset("assets/shopping-cart.png", color: careysPink,),
              activeItem: Image.asset("assets/shopping-cart.png", color: careysPink,),
            ),
            const BottomBarItem(
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
