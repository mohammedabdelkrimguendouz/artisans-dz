import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../screens/home_page.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../core/constants/spacing.dart';
import '../navigation/navigation_extension.dart';
import 'package:artisans_dz/data/services/supabase_service.dart';
import 'package:artisans_dz/core/utils/util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late SupabaseService supabaseService;
  @override
  void initState() {
    super.initState();
    //_handleIncomingLinks();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  // Future<void> _handleIncomingLinks() async {
  //   try {
  //     uriLinkStream.listen((Uri? uri) async {
  //       if (uri != null) {
  //         final response = await supabaseService.supabase.auth.getSessionFromUrl(uri);
  //         if (response.session != null) {
  //           context.navigateTo(HomePage());
  //         } else {
  //         }
  //       }
  //     }, onError: (err) {
  //     });
  //   } catch (e) {
  //   }
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    Util.showLoadingDialog(context, 'جاري تسجيل الدخول...');


    try {

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      final success = await SupabaseService().signIn(
          email,password
      );




      if (success==true) {



        if (mounted)
        {
          Navigator.of(context).pop();
          context.navigateTo(HomePage());
        }



      } else {



        Navigator.of(context).pop();
        Util.showSnackBarMessage(
            context, 'فشل تسجيل الدخول. تأكد من البيانات وحاول مرة أخرى.', Colors.red);
      }
    } catch (e) {


      Navigator.of(context).pop();
      Util.showSnackBarMessage(
          context,'حدث خطأ أثناء تسجيل الدخول $e', Colors.red);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildLoginForm(),
                      const SizedBox(height: 10),
                      _buildForgotPassword(),
                      const SizedBox(height: 20),
                      _buildLoginButton(),
                      const SizedBox(height: 15),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'images/login.png',
          width: MediaQuery.of(context).size.width * 0.2,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            size: 120,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'مرحباً بعودتك',
          style: TextStyle(
            fontSize: AppSpacing.sizeTitle,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'سجل دخولك الآن للوصول إلى جميع الميزات',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            hintText: 'البريد الإلكتروني',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'حقل البريد الإلكتروني مطلوب';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'البريد الإلكتروني غير صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _passwordController,
            hintText: 'كلمة المرور',
            prefixIcon: Icons.lock_outline,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ?Icons.visibility: Icons.visibility_off ,
                color: AppColors.textLight,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'حقل كلمة المرور مطلوب';
              }
              if (value.length < 8) {
                return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          context.pushTo(ForgotPasswordScreen());
        },
        child: const Text(
          'هل نسيت كلمة المرور؟',
          style: TextStyle(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return CustomButton(
      width: double.infinity,
      height: 56,
      onPressed: _login,
      backgroundColor: AppColors.primary,
      icon: Icons.login,
      label: 'تسجيل الدخول',
      textColor: AppColors.white,
      borderRadius: AppSpacing.borderRadius,
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            color: AppColors.textLight,
          ),
        ),
        TextButton(
          onPressed: () {
            context.pushTo(RegisterScreen());
          },
          child:  Text(
            'إنشاء حساب جديد',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

