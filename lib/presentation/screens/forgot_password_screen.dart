import 'package:artisans_dz/data/services/email_service.dart';
import 'package:artisans_dz/data/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../widgets/custom_text_field.dart';
import '../../core/constants/spacing.dart';
import '../widgets/custom_button.dart';
import '../navigation/navigation_extension.dart';
import 'package:artisans_dz/core/utils/util.dart';
import 'reset_password_screen.dart'; // شاشة تغيير كلمة المرور

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _emailVerified = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailAndSendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    Util.showLoadingDialog(context, 'يتم ارسال الرمز...');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String email = _emailController.text.trim();

    try {
      setState(() {
        _emailVerified = true;
      });

      final otpCode = Util.generateOTP();
      String subject = 'إعادة تعيين كلمة المرور';
      String body = """
مرحبًا ،

لقد تلقينا طلبًا لإعادة تعيين كلمة المرور الخاصة بحسابك.
استخدم رمز التحقق التالي لإكمال العملية:

رمز التحقق: $otpCode


إذا لم تطلب هذا، يرجى تجاهل الرسالة فورًا لحماية حسابك.
""";

      await SupabaseService().saveVerificationOTPCode(email, otpCode);

      final success = await EmailService.sendEmail(
        recipientEmail: email,
        subject: subject,
        body: body,
      );

      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
          _otpSent = success;
        });
      }

      if (!success) {
        Navigator.of(context).pop();
        Util.showSnackBarMessage(
          context,
          'حدث خطأ أثناء إرسال رمز التحقق',
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
          _errorMessage = 'البريد الإلكتروني غير مسجل في النظام';
        });
      }
    }
  }

  Future<void> _verifyOTP() async {
    final email = _emailController.text.trim();
    final OTP = _otpController.text.trim();

    if (OTP.isEmpty || OTP.length != 6) {
      setState(() {
        _errorMessage = 'الرجاء إدخال رمز التحقق المكون من 6 أرقام';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SupabaseService().verifyOTPCode(email, OTP);

      if (response == true) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: email,codeOTP: OTP),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'رمز التحقق غير صحيح';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء التحقق من الرمز';
      });
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child:
                    _otpVerified
                        ? _buildSuccessView()
                        : _otpSent
                        ? _buildOTPVerificationForm()
                        : _buildEmailRequestForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailRequestForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Image.asset(
            'images/reset_password.png',
            width: MediaQuery.of(context).size.width * 0.2,
            fit: BoxFit.contain,
            errorBuilder:
                (context, error, stackTrace) => Icon(
                  Icons.lock_reset,
                  size: 120,
                  color: AppColors.primary.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          const Text(
            'استعادة كلمة المرور',
            style: TextStyle(
              fontSize: AppSpacing.sizeTitle,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'أدخل بريدك الإلكتروني المسجل وسنرسل لك رمز التحقق',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSpacing.sizeDescription,
              color: AppColors.textLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hintText: 'البريد الإلكتروني',
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يجب إدخال البريد الإلكتروني';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'البريد الإلكتروني غير صحيح';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CustomButton(
              icon: Icons.send,
              onPressed: _isLoading ? () {} : _checkEmailAndSendOTP,
              label: 'إرسال رمز التحقق',
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              borderRadius: AppSpacing.borderRadius,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPVerificationForm() {
    return Column(
      children: [
        Icon(Icons.email_outlined, size: 120, color: AppColors.primary),
        const SizedBox(height: 24),
        const Text(
          'أدخل رمز التحقق',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'تم إرسال رمز التحقق إلى:\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textLight,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          hintText: 'رمز التحقق المكون من 6 أرقام',
          prefixIcon: Icons.lock_outline,
          maxLength: 6,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: CustomButton(
                  icon: Icons.arrow_back,
                  onPressed:
                      _isLoading
                          ? () {}
                          : () {
                            setState(() {
                              _otpSent = false;
                              _errorMessage = null;
                            });
                          },
                  label: 'رجوع',
                  backgroundColor: Colors.grey[300]!,
                  textColor: AppColors.textDark,
                  borderRadius: AppSpacing.borderRadius,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 50,
                child: CustomButton(
                  icon: Icons.verified,
                  onPressed: _isLoading ? () {} : _verifyOTP,
                  label: 'تحقق',
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  borderRadius: AppSpacing.borderRadius,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await _checkEmailAndSendOTP();
                    setState(() {
                      _isLoading = false;
                    });
                  },
          child: const Text(
            'إعادة إرسال رمز التحقق',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Icon(Icons.check_circle, size: 120, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'تم التحقق بنجاح',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'يمكنك الآن تعيين كلمة مرور جديدة لحسابك',
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
            icon: Icons.change_circle,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ResetPasswordScreen(
                        email: _emailController.text.trim(),
                        codeOTP: _otpController.text.trim(),
                      ),
                ),
              );
            },
            label: 'تغيير كلمة المرور',
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            borderRadius: AppSpacing.borderRadius,
          ),
        ),
      ],
    );
  }
}
