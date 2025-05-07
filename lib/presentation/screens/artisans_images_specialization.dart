import 'package:artisans_dz/core/constants/colors.dart';
import 'package:artisans_dz/core/constants/spacing.dart';
import 'package:artisans_dz/core/utils/util.dart';
import 'package:artisans_dz/data/models/artisan_image_model.dart';
import 'package:artisans_dz/data/models/artisan_model.dart';
import 'package:artisans_dz/data/models/artisan_specialization_model.dart';
import 'package:artisans_dz/data/models/specialization_model.dart';
import 'package:artisans_dz/data/services/storage_settings.dart';
import 'package:artisans_dz/data/services/supabase_service.dart';
import 'package:artisans_dz/data/services/user_preferences.dart';
import 'package:artisans_dz/env.env';
import 'package:artisans_dz/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArtisansImagesSpecialization extends StatefulWidget {
  const ArtisansImagesSpecialization({super.key});

  @override
  State<ArtisansImagesSpecialization> createState() => _ArtisansImagesSpecializationState();
}

class _ArtisansImagesSpecializationState extends State<ArtisansImagesSpecialization> {
  final supabase = Supabase.instance.client;
  Artisan? artisan;
  bool isLoading = true;

  List<Specialization> availableSpecializations = [];
  Specialization? selectedSpecialization;

  @override
  void initState() {
    super.initState();
    _loadArtisan();
    _loadAvailableSpecializations();
  }

  Future<void> _loadArtisan() async {
    final artisanData = await UserPreferences.getArtisan();
    if (artisanData != null) {
      setState(() {
        artisan = artisanData;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableSpecializations() async {

    final result = await SupabaseService().getSpecializations();
      setState(() {
        availableSpecializations = result;
      });

  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file != null) {
       Util.showLoadingDialog(context, 'جاري رفع الصورة...');

      try {
        final fileBytes = await file.readAsBytes();
        final filePath = 'artisans/${artisan!.artisanId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from(StorageSettings.bucketArtisanImages).uploadBinary(filePath, fileBytes);
        final imageUrl = supabase.storage.from(StorageSettings.bucketArtisanImages).getPublicUrl(filePath);


        final ArtisanImage? artisanImage = await SupabaseService().addImageToArtisan(imageUrl, artisan!.artisanId);
        setState(() {
          artisan!.images.add(ArtisanImage(
              artisanId: artisanImage!.artisanId,
              artisanImageId: artisanImage.artisanImageId,
              imageUrl: imageUrl
          ));

          UserPreferences.saveArtisan(artisan!);

        });

        Navigator.of(context).pop();

        // إظهار رسالة نجاح
        Util.showSnackBarMessage(context,'تم إضافة الصورة بنجاح', Colors.green);
      } catch (e) {
        // إغلاق مؤشر التحميل
        Navigator.of(context).pop();
        Util.showSnackBarMessage(context,'حدث خطأ أثناء رفع الصورة', Colors.red);
      }
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    // تأكيد الحذف
    final shouldDelete = await Util.showDialogConfirmation(context,'تاكيد','هل أنت متأكد من حذف هذه الصورة؟',
    'حذف','الغاء',Colors.red);

    if (shouldDelete == true) {
      try {
        Util.showLoadingDialog(context, 'جاري حذف الصورة...');

        final path = Uri.parse(imageUrl).pathSegments.skip(1).join('/');
        await supabase.storage.from('artisan_images').remove([path]);

        await SupabaseService().removeImageArtisan(imageUrl, artisan!.artisanId);

        setState(() {
          artisan!.images.removeWhere((img) => img.imageUrl == imageUrl);
          UserPreferences.saveArtisan(artisan!);
        });

        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        Util.showSnackBarMessage(context,'تم حذف الصورة بنجاح', Colors.green);
      } catch (e) {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        Util.showSnackBarMessage(context,'حدث خطأ أثناء حذف الصورة', Colors.red);
      }
    }
  }

  Future<void> _addSpecialization() async {
    if (selectedSpecialization != null) {
      final exists = artisan!.specializations.any(
              (s) => s.name == selectedSpecialization!.name
      );

      if (exists) {
        Util.showSnackBarMessage(context,'هذا التخصص موجود مسبقاً', Colors.orange);
        return;
      }

      try {
        Util.showLoadingDialog(context, 'جاري إضافة التخصص...');

        final ArtisanSpecialization? artisanSpecialization = await SupabaseService().addSpecializationToArtisan(selectedSpecialization!.specializationId, artisan!.artisanId);

        setState(() {
            artisan!.specializations.add(Specialization(name: selectedSpecialization!.name,
            specializationId:selectedSpecialization!.specializationId,
            imageUrl: selectedSpecialization!.imageUrl));

            UserPreferences.saveArtisan(artisan!);

            selectedSpecialization = null;
        });

        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        Util.showSnackBarMessage(context,'تم إضافة التخصص بنجاح', Colors.green);
      } catch (e) {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        Util.showSnackBarMessage(context,'حدث خطأ أثناء إضافة التخصص', Colors.red);
      }
    } else {
      Util.showSnackBarMessage(context,'الرجاء اختيار تخصص', Colors.orange);
    }
  }

  Future<void> _removeSpecialization(Specialization specialization) async {
    // تأكيد الحذف
    final shouldDelete = await Util.showDialogConfirmation(context,'تاكيد','هل أنت متأكد من حذف هذا التخصص؟',
        'حذف','الغاء',Colors.red);


    if (shouldDelete == true) {
      try {
        Util.showLoadingDialog(context, 'جاري حذف التخصص...');

        await SupabaseService().removeSpecializationArtisan(specialization.specializationId, artisan!.artisanId);

        setState(() {
          artisan!.specializations.removeWhere((s) => s.name == specialization.name);
          UserPreferences.saveArtisan(artisan!);
        });

        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        Util.showSnackBarMessage(context,'تم حذف التخصص بنجاح', Colors.green);
      } catch (e) {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        Util.showSnackBarMessage(context,'حدث خطأ أثناء حذف التخصص', Colors.red);
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ملف الحرفي'),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: () async {
            await _loadArtisan();
            await _loadAvailableSpecializations();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAddSpecializationSection(),
              const SizedBox(height: 16),
              _buildSpecializationsSection(),
              const SizedBox(height: 16),
              _buildImagesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddSpecializationSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة تخصص جديد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Specialization>(
                  isExpanded: true,
                  value: selectedSpecialization,
                  hint: const Text('اختر تخصصًا'),
                  items: availableSpecializations
                      .map((spec) {
                    return DropdownMenuItem<Specialization>(
                      value: spec,
                      child: Text(spec.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialization = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة تخصص'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _addSpecialization,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializationsSection() {
    if (artisan!.specializations.isEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'لا توجد تخصصات مضافة',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التخصصات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: artisan!.specializations.map((spec) {
                return Chip(
                  label: Text(spec.name),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeSpecialization(spec),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: const TextStyle(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'معرض الأعمال',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text( 'إضافة صورة'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                    ),
                  ),
                  onPressed: _addImage,
                ),
              ],
            ),
            const Divider(),
            artisan!.images.isEmpty
                ? const Center(
              heightFactor: 3,
              child: Text(
                'لا توجد صور في المعرض',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: artisan!.images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final image = artisan!.images[index];
                return InkWell(
                  onTap: () => _showImageFullScreen(image.imageUrl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: image.imageUrl,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 14,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                            onPressed: () => _deleteImage(image.imageUrl),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImageFullScreen(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}