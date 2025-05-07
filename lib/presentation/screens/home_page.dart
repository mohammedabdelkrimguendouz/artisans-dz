import 'package:artisans_dz/presentation/screens/artisans_images_specialization.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
// import '../screens/favorites_screen.dart';
// import '../screens/messages_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<Widget> pages;
  late HomeScreen homeScreen;
  late ProfileScreen profileScreen;
  late ArtisansImagesSpecialization artisansImagesSpecialization;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    homeScreen = HomeScreen();
    profileScreen = ProfileScreen();
    artisansImagesSpecialization = ArtisansImagesSpecialization();
    pages = [homeScreen,artisansImagesSpecialization,profileScreen];
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    super.dispose();
  }
  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          children: pages,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: AppColors.white,
          color: AppColors.primary,
          buttonBackgroundColor: AppColors.white,
          height: 60,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          items: [
            Icon(
              Icons.home,
              size: AppSpacing.sizeIconHomePage,
              color: _selectedIndex == 0 ? AppColors.primary : AppColors.white,
            ),
            Icon(
              Icons.engineering,
              size: AppSpacing.sizeIconHomePage,
              color: _selectedIndex == 1 ? AppColors.primary : AppColors.white,
            ),
            Icon(
              Icons.person,
              size: AppSpacing.sizeIconHomePage,
              color: _selectedIndex == 2 ? AppColors.primary : AppColors.white,
            ),
          ],

          index: _selectedIndex,
          onTap: onTabTapped,
        ),
      ),
    );
  }
}
