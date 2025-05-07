import 'dart:io';
import 'package:artisans_dz/core/constants/spacing.dart';
import 'package:artisans_dz/data/models/wilaya_model.dart';
import 'package:artisans_dz/data/services/storage_settings.dart';
import 'package:artisans_dz/presentation/navigation/navigation_extension.dart';
import 'package:artisans_dz/presentation/screens/welcome_screen.dart';
import 'package:artisans_dz/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:artisans_dz/data/models/artisan_model.dart';
import 'package:artisans_dz/data/services/user_preferences.dart';
import 'package:artisans_dz/data/services/supabase_service.dart';
import 'package:artisans_dz/core/utils/util.dart';
import 'package:artisans_dz/core/constants/colors.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artisans_dz/presentation/widgets/custom_text_field.dart';
import 'package:artisans_dz/presentation/screens/change_password_screen.dart';
import '../navigation/navigation_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Artisan? artisan;
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();
  final _imagePicker = ImagePicker();

  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController bioController;
  late List<Wilaya> wilayas = List<Wilaya>.empty();
  Wilaya? selectedWilaya;

  bool isLoading = true;
  bool isSaving = false;
  File? _selectedImageFile;

  @override
  void initState(){
    super.initState();
    _loadArtisanData();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.location.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<void> getCurrentLocation() async {



    bool hasPermission = await requestLocationPermission();

    if (!hasPermission) {
      return;
    }

    Util.showLoadingDialog(context, 'جاري تحديد الموقع...');

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );



      artisan?.latitude =  position.latitude;
      artisan?.longitude = position.longitude;


      Navigator.of(context).pop();
      Util.showSnackBarMessage(
          context, 'تم تحديد الموقع ينجاح', Colors.green);

    } catch (e) {
      Navigator.of(context).pop();
      Util.showSnackBarMessage(
          context, 'فشل تحديد الموقع', Colors.red);

    }
  }


  Future<void> _openGoogleMaps() async {
    if (artisan?.latitude == null || artisan?.longitude == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${artisan!.latitude},${artisan!.longitude}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      Util.showSnackBarMessage(context, 'تعذر فتح خرائط جوجل: $e', Colors.red);
    }
  }

  Future<void> _copyCoordinates() async {
    if (artisan?.latitude == null || artisan?.longitude == null) return;

    await Clipboard.setData(
      ClipboardData(
        text: '${artisan!.latitude}, ${artisan!.longitude}',
      ),
    );

    if (mounted) {
      Util.showSnackBarMessage(context, 'تم نسخ الإحداثيات', Colors.green);
    }
  }


  void _getWilayas() async {
    try {
      final result = await SupabaseService().getWilayas();
      if (mounted) {
        setState(() {
          wilayas = result;
          if (artisan != null && artisan!.wilaya != null) {
            selectedWilaya = artisan!.wilaya;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Util.showSnackBarMessage(context, 'فشل في تحميل قائمة الولايات', Colors.red);
      }
    }
  }


  Future<void> _loadArtisanData() async {
    setState(() => isLoading = true);

    try {
      final storedArtisan = await UserPreferences.getArtisan();
      if (storedArtisan != null && mounted) {
        setState(() {
          artisan = storedArtisan;
          fullNameController = TextEditingController(text: artisan!.fullName);
          phoneController = TextEditingController(text: artisan!.phone ?? '');
          bioController = TextEditingController(text: artisan!.bio ?? '');
          isLoading = false;
        });
        _getWilayas();
      } else if (mounted) {
        Util.showSnackBarMessage(context, 'فشل في تحميل بيانات الملف الشخصي', Colors.red);
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        Util.showSnackBarMessage(context, 'خطأ في تحميل البيانات', Colors.red);
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImageFile = File(pickedImage.path);
        });
      }
    } catch (e) {
      Util.showSnackBarMessage(context, 'خطأ في اختيار الصورة: ${e.toString()}', Colors.red);
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedImageFile == null || artisan == null) return null;

    try {
      final supabase = _supabaseService.supabase;
      final userId = artisan!.uid;
      final fileExtension = path.extension(_selectedImageFile!.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_$userId\_$timestamp$fileExtension';

      await supabase
          .storage
          .from(StorageSettings.bucketArtisanProfiles)
          .upload(
        fileName,
        _selectedImageFile!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final imageUrl = supabase
          .storage
          .from(StorageSettings.bucketArtisanProfiles)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && artisan != null) {
      setState(() => isSaving = true);

      Util.showLoadingDialog(context, 'جاري الحفظ...');

      try {
        String? imageUrl;

        if (_selectedImageFile != null) {
          imageUrl = await _uploadProfileImage();
          if (imageUrl == null) {
            Util.showSnackBarMessage(context, 'فشل في رفع الصورة', Colors.red);
            setState(() => isSaving = false);
            return;
          }
        }


        final updated = Artisan(
          artisanId: artisan!.artisanId,
          uid: artisan!.uid,
          fullName: fullNameController.text,
          phone: phoneController.text,
          wilaya: selectedWilaya!,
          createdDate: artisan!.createdDate,
          bio: bioController.text,
          profileImage: imageUrl ?? artisan!.profileImage,
          latitude: artisan!.latitude,
          longitude: artisan!.longitude,
          specializations: artisan!.specializations,
          images: artisan!.images,
        );

        final result = await  _supabaseService.updateArtisanProfile(updated);

        if (result) {

          await UserPreferences.saveArtisan(updated);

          setState(() {
            artisan = updated;
            isSaving = false;
            _selectedImageFile = null;
          });

          Navigator.of(context).pop();
          Util.showSnackBarMessage(context, 'تم تحديث الملف الشخصي بنجاح', Colors.green);
        } else {
          Util.showSnackBarMessage(context, 'فشل تحديث الملف الشخصي', Colors.red);
          setState(() => isSaving = false);
        }
      } catch (e) {
        Navigator.of(context).pop();
        Util.showSnackBarMessage(context, 'خطأ: ${e.toString()}', Colors.red);
        setState(() => isSaving = false);
      }
    }
  }



  Future<void> _logout() async {
    try {


      await _supabaseService.supabase.auth.signOut();

      await UserPreferences.clearArtisan();


      context.navigateTo(WelcomeScreen());
    } catch (e) {


      Util.showSnackBarMessage(context, 'خطأ في تسجيل الخروج: ${e.toString()}', Colors.red);
    }
  }

  void _showLogoutDialog() async {

     final isShouldLogOut = await Util.showDialogConfirmation(context,'تسجيل الخروج',
         'هل أنت متأكد أنك تريد تسجيل الخروج؟', 'تسجيل الخروج', 'إلغاء',Colors.red);




     if(isShouldLogOut==true)
     {

         _logout();
     }

  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 4,
              ),
            ),
            child: ClipOval(
              child: _selectedImageFile != null
                  ? Image.file(
                _selectedImageFile!,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              )
                  : artisan?.profileImage != null
                  ? Image.network(
                artisan!.profileImage!,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  );
                },
              )
                  : const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: isSaving ? null : _pickImage,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلومات الشخصية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            CustomTextField(
              controller: fullNameController,
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
              controller: phoneController,
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
            CustomTextField(
              controller: bioController,
              hintText: 'السيرة الذاتية',
              prefixIcon: Icons.description,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الموقع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (artisan?.latitude == null || artisan?.longitude == null)
                  TextButton(
                    onPressed: getCurrentLocation,
                    child: const Text('تحديد موقعي الحالي'),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildWilayaOption(),
            if (artisan?.latitude != null && artisan?.longitude != null) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإحداثيات:',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: _copyCoordinates,
                              tooltip: 'نسخ الإحداثيات',
                            ),
                            IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: _openGoogleMaps,
                              tooltip: 'فتح في خرائط جوجل',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'خط العرض: ${artisan!.latitude!.toStringAsFixed(6)}\n'
                          'خط الطول: ${artisan!.longitude!.toStringAsFixed(6)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: getCurrentLocation,
                      child: const Text('تحديث الموقع الحالي'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget _buildLocationSection() {
  //   return Card(
  //     elevation: 2,
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'الموقع',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: AppColors.primary,
  //             ),
  //           ),
  //           const Divider(),
  //           const SizedBox(height: 16),
  //           CustomTextField(
  //             enabled: false,
  //             prefixIcon: Icons.location_city,
  //             hintText: 'الولاية',
  //           ),
  //           if (artisan?.latitude != null && artisan?.longitude != null)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 16),
  //               child: Container(
  //                 height: 150,
  //                 width: double.infinity,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey[200],
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Center(
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(Icons.map, size: 40, color: AppColors.primary),
  //                       const SizedBox(height: 8),
  //                       Text(
  //                         'خط العرض: ${artisan!.latitude!.toStringAsFixed(6)}\n'
  //                             'خط الطول: ${artisan!.longitude!.toStringAsFixed(6)}',
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              ),
              tooltip: 'تغيير كلمة المرور',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showLogoutDialog,
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
            : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileImage(),
              const SizedBox(height: 16),
              _buildInformationSection(),
              _buildLocationSection(),
              const SizedBox(height: 24),

              CustomButton(
                icon: Icons.save,
                backgroundColor: AppColors.primary,
                textColor: AppColors.white,
                borderRadius: AppSpacing.borderRadius,
                onPressed: isSaving ? (){} : _saveProfile,
                label:  'حفظ التغييرات',
              ),

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildWilayaOption() {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<Wilaya>(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.location_city),
          prefixIconColor: AppColors.primary,
          labelText: 'الولاية',
          hintText: 'اختر ولايتك',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.secondary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        value: selectedWilaya,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        validator: (value) {
          if (wilayas.isEmpty) return 'لا توجد ولايات متاحة';
          if (value == null) return 'يجب اختيار الولاية';
          return null;
        },
        onChanged: isSaving ? null : (Wilaya? newValue) {
          setState(() {
            selectedWilaya = newValue;
          });
        },
        items: wilayas.map((Wilaya item) {
          return DropdownMenuItem<Wilaya>(
            value: item,
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
      ),
    );
  }
}