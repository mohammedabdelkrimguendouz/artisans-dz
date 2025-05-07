import 'package:artisans_dz/core/constants/colors.dart';
import 'package:artisans_dz/core/constants/spacing.dart';
import 'package:artisans_dz/core/utils/util.dart';
import 'package:artisans_dz/data/models/artisan_model.dart';
import 'package:artisans_dz/data/services/supabase_service.dart';
import 'package:artisans_dz/data/services/user_preferences.dart';
import 'package:artisans_dz/presentation/widgets/custom_button.dart';
import 'package:artisans_dz/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../navigation/navigation_extension.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final String? emailCurrentArtisan = Supabase.instance.client.auth.currentUser?.email;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _currentPasswordVerifed = false;

  void _verifyCurrentPassword() async {
    bool result = await SupabaseService().verifyCurrentPassword(
        Supabase.instance.client.auth.currentUser?.email,
        currentPasswordController.text.trim()
    );

    setState(() {
      _currentPasswordVerifed = result;
    });


  }

  void _changePassword() async {



    try
    {



      String? email = Supabase.instance.client.auth.currentUser!.email;

      if (_formKey.currentState!.validate()) {
        Util.showLoadingDialog(context, 'جاري تغيير كلمة المرور...');

        final isChanged = await SupabaseService().changePassword(email!,
            newPasswordController.text.trim());

        if (isChanged==true)
          {
            Navigator.of(context).pop();
            Util.showSnackBarMessage(context, 'تم تغيير كبمة المرور بنجاح', Colors.green);
          }

        else
          {
            Navigator.of(context).pop();
            Util.showSnackBarMessage(
                context, ' لم يتم تغيير كلمة المرور بنجاح', Colors.red);
          }

      }
    }
    catch(e)
    {
      Navigator.of(context).pop();
      Util.showSnackBarMessage(
          context, 'حدث خطا اثناء تغيير كلمة المرور', Colors.red);
    }


  }

  @override
  void initState() {
    _verifyCurrentPassword();
    super.initState();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text('تغيير كلمة المرور'),
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: currentPasswordController,
                  onChanged:(_)=> _verifyCurrentPassword(),
                  hintText: 'كلمة المرور الحالية',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureCurrent,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrent = !_obscureCurrent;
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
                    if (!_currentPasswordVerifed) {
                    return 'كلمة المرور غير صحيحة';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                CustomTextField(
                  controller: newPasswordController,
                  hintText: 'كلمة المرور الجديدة',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureNew,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
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


                SizedBox(height: 16),


                CustomTextField(
                  controller: confirmPasswordController,
                  hintText: 'تأكيد كلمة المرور الجديدة',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب تأكيد كلمة المرور';
                    }
                    if (value != newPasswordController.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24),
                CustomButton(
                  icon: Icons.save,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  borderRadius: AppSpacing.borderRadius,
                  onPressed: _changePassword,
                  label:  'تحديث',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
