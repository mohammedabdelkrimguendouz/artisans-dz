import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../screens/home_screen.dart';
import '../screens/register_screen.dart';
import '../widgets/custom_button.dart';
import '../navigation/navigation_extension.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.white.withOpacity(0.9),
                AppColors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 4, // قلل من قيمة flex
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Image.asset(
                        'images/artisen_dz.png',
                        width: MediaQuery.of(context).size.width * 0.9,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 120,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),


                Expanded(
                  flex: 6,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: IntrinsicHeight(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'مرحباً بك في دليل الحرفيين',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: AppSpacing.sizeTitle,
                                          fontWeight: FontWeight.bold,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'اكتشف أفضل الحرفيين المحترفين في منطقتك',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.textLight,
                                          fontSize: AppSpacing.sizeDescription,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'أو انضم إلينا لعرض مهاراتك',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.white70,
                                          fontSize: AppSpacing.sizeDescription,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      CustomButton(
                                        icon: Icons.search,
                                        label: 'استكشف الحرفيين',
                                        onPressed: () => context.pushTo(HomeScreen()),
                                        backgroundColor: AppColors.primary,
                                        textColor: AppColors.white,
                                        borderRadius: AppSpacing.borderRadius,
                                      ),

                                      const SizedBox(height: 25),

                                      CustomButton(
                                        icon: Icons.work_outline,
                                        label: 'تسجيل كحرفي',
                                        onPressed: () => context.pushTo(RegisterScreen()),
                                        backgroundColor: AppColors.transparent,
                                        textColor: AppColors.primary,
                                        borderColor: AppColors.primary,
                                        borderRadius: AppSpacing.borderRadius,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}