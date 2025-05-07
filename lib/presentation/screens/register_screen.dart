import 'package:artisans_dz/data/models/wilaya_model.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'login_screen.dart';
import '../screens/home_page.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../core/constants/spacing.dart';
import '../navigation/navigation_extension.dart';
import 'package:artisans_dz/data/services/supabase_service.dart';
import 'package:artisans_dz/core/utils/util.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  late List<Wilaya> wilayas = List<Wilaya>.empty();
  Wilaya? selectedWilaya;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _currentStep = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    getWilayas();
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void getWilayas() async {
    final result = await SupabaseService().getWilayas();
    setState(() {
      wilayas = result;
    });
  }


  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Util.showLoadingDialog(context, 'جاري التسجيل...');



    try {
      bool success = await SupabaseService().signUp(
        email: _emailController.text.trim(),
        fullname: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        wilayaid: selectedWilaya?.wilayaId??-1,
      );

      if(success)
      {
        if (mounted)
          {
            Navigator.of(context).pop();
            context.navigateTo(HomePage());
          }
      }
      else {

        Navigator.of(context).pop();
        Util.showSnackBarMessage(
            context, 'فشل التسجيل . تأكد من البيانات وحاول مرة أخرى.', Colors.red);
      }

    } catch (e) {

      Navigator.of(context).pop();
      Util.showSnackBarMessage(
          context,'فشل في عملية التسجيل، يرجى المحاولة لاحقاً', Colors.red);
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep -= 1;
    });
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset(
                        'images/register.png',
                        width: MediaQuery.of(context).size.width * 0.2,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person_add_alt_1,
                          size: 120,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStepIndicator(),
                      const SizedBox(height: 30),
                      _buildCurrentStepContent(),
                      const SizedBox(height: 30),
                      _buildNavigationButtons(),
                      if (_currentStep == 0) ...[
                        const SizedBox(height: 24),
                        _buildLoginLink(),
                      ],
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

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(0, 'المعلومات الشخصية'),
        _buildStepConnector(),
        _buildStepCircle(1, 'معلومات الحساب'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
              '${step + 1}',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 50,
      height: 2,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildAccountInfoStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          hintText: 'الاسم الكامل',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يجب إدخال الاسم الكامل';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        CustomTextField(
          controller: _phoneController,
          hintText: 'رقم الجوال',
          prefixIcon: Icons.phone_android,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يجب إدخال رقم الجوال';
            }
            if (!RegExp(r'^(0)(5|6|7)[0-9]{8}$').hasMatch(value)) {
              return 'رقم الهاتف  غير صحيح';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        _buildWilayaOption()


      ],
    );
  }

  Widget _buildWilayaOption() {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<Wilaya>(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_city),
          prefixIconColor: AppColors.primary,
          labelText: 'الولايات',
          hintText: 'اختر ولايتك',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor:  AppColors.secondary,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        value:selectedWilaya,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        validator: (value) {
          if (value == null || value.name.isEmpty) {
            return 'يجب اختيار الولاية';
          }
          return null;
        },
        onChanged: (Wilaya? newValue) {
          setState(() {
            selectedWilaya = newValue;
          });
        },
        items: wilayas.map((Wilaya item) {
          return DropdownMenuItem<Wilaya>(
            value: item,
            child: Text(
              item.name,
              style: TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountInfoStep() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: 'البريد الإلكتروني',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يجب إدخال البريد الإلكتروني';
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
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
              return 'يجب إدخال كلمة المرور';
            }
            if (value.length < 8) {
              return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'تأكيد كلمة المرور',
          prefixIcon: Icons.lock_outline,
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textLight,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يجب تأكيد كلمة المرور';
            }
            if (value != _passwordController.text) {
              return 'كلمة المرور غير متطابقة';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    if (_currentStep == 0) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: CustomButton(
          icon: Icons.navigate_next,
          onPressed: _nextStep,
          label: 'التالي',
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          borderRadius: AppSpacing.borderRadius,
        ),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: CustomButton(
                onPressed: _previousStep,
                label: 'السابق',
                icon: Icons.navigate_before,
                backgroundColor: AppColors.primary,
                textColor: AppColors.white,
                borderRadius: AppSpacing.borderRadius,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: SizedBox(
              height: 50,
              child: CustomButton(
                icon: Icons.add_chart_sharp,
                backgroundColor: AppColors.primary,
                textColor: AppColors.white,
                borderRadius: AppSpacing.borderRadius,
                onPressed: _register,
                label:  'إنشاء الحساب',
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            color: AppColors.textLight,
          ),
        ),
        TextButton(
          onPressed: () {
            context.pushTo(LoginScreen());
          },
          child: Text(
            'تسجيل الدخول',
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