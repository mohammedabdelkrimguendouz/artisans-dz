import 'package:artisans_dz/data/services/supabase_service.dart';
import 'package:artisans_dz/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../widgets/custom_text_field.dart';
import '../../core/constants/spacing.dart';
import '../widgets/custom_button.dart';
import '../navigation/navigation_extension.dart';
import 'package:artisans_dz/core/utils/util.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String codeOTP;

  const ResetPasswordScreen({Key? key, required this.email,required this.codeOTP}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordReset = false;
  String? _errorMessage;
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });



    try {

      final response = await SupabaseService().
      changePasswordWithCode(email:  widget.email ,code:  widget.codeOTP,
          newPassword: _passwordController.text.trim());



      if (response==true) {
        setState(() {
          _passwordReset = true;
        });
      } else {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء تحديث كلمة المرور';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحديث كلمة المرور';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _passwordReset
                  ? _buildSuccessView()
                  : _buildResetPasswordForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Icon(
            Icons.lock_reset,
            size: 120,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'تعيين كلمة مرور جديدة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لحساب: ${widget.email}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _passwordController,
            obscureText: true,
            hintText: 'كلمة المرور الجديدة',
            prefixIcon: Icons.lock_outline,
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
            obscureText: true,
            hintText: 'تأكيد كلمة المرور',
            prefixIcon: Icons.lock_outline,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'كلمة المرور غير متطابقة';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CustomButton(
              icon: Icons.lock_reset,
              onPressed: _isLoading ? (){} : _resetPassword,
              label: 'تعيين كلمة المرور',
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              borderRadius: AppSpacing.borderRadius,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSuccessView() {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          size: 120,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        const Text(
          'تم تغيير كلمة المرور بنجاح',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'يمكنك الآن تسجيل الدخول باستخدام كلمة المرور الجديدة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textLight,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            icon: Icons.arrow_back_outlined,
            onPressed: () {
              context.navigateTo(LoginScreen());
            },
            label: 'العودة لتسجيل الدخول',
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            borderRadius: AppSpacing.borderRadius,
          ),
        ),
      ],
    );
  }
}