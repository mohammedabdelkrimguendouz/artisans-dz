import 'package:artisans_dz/data/models/artisan_image_model.dart';
import 'package:artisans_dz/data/models/artisan_specialization_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artisans_dz/data/models/wilaya_model.dart';
import 'package:artisans_dz/data/models/artisan_model.dart';
import 'package:artisans_dz/data/models/specialization_model.dart';
import 'package:artisans_dz/data/services/user_preferences.dart';

class SupabaseService {
    final supabase = Supabase.instance.client;
    List<Specialization> _cachedSpecializations = new List<Specialization>.empty();













    Future<bool> signIn(String email, String password) async {
      try {
        final response = await supabase.auth
            .signInWithPassword(email: email, password: password);
        final userId = response.user?.id;

        if (userId != null) {
          final response = await supabase
              .from('artisans_detailed_view')
              .select('*')
              .eq('uid', userId)
              .single();

          final artisan = Artisan.fromJson(response);
          await UserPreferences.saveArtisan(artisan);

          return true;
        } else {
          return false;
        }
      } on AuthException catch (e) {
        return false;
      } catch (e) {
        return false;
      }
    }


    Future<bool> signUp({
      required String fullname,
      required String email,
      required String password,
      required String phone,
      required int wilayaid,
    }) async {
      try {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final userId = response.user?.id;
        if (userId != null) {
          final insertResult = await supabase.from('artisans').insert({
            'uid': userId,
            'fullname': fullname,
            'phone': phone,
            'wilayaid': wilayaid,
            'createddate': DateTime.now().toIso8601String(),
            'bio': null,
            'profileimage': null,
            'latitude': null,
            'longitude': null,
          });

              final artisanDetails = await supabase.from('artisans_detailed_view')
              .select('*')
              .eq('uid', userId)
              .single();

          final artisan = Artisan.fromJson(artisanDetails);




          await UserPreferences.saveArtisan(artisan);

          return true;
        } else {
          return false;
        }
      } catch (error) {
        return false;
      }
    }




    Future<List<Wilaya>> getWilayas() async {
     final response = await supabase.from('wilayas').select();

     List<Wilaya> wilayas = response.map<Wilaya>((map) => Wilaya.fromJson(map)).toList();
     return wilayas;
   }

   Future<bool> resetPassword(String email) async {
     try {
       await supabase.auth.resetPasswordForEmail(email);
       return true;
     } catch (e) {
       return false;
     }
   }


    Future<List<Artisan>> getArtisans() async {
      try {
        final response = await supabase
            .from('artisans_detailed_view')
            .select('*');
          return response.map<Artisan>((json) => Artisan.fromJson(json)).toList();
      } catch (e) {
        return  List<Artisan>.empty();
      }
    }



    Future<List<Artisan>> getArtisansBySpecializationAndWilaya(int specializationId, int? wilayaId) async {
      try {
        var query = supabase
            .from('artisans_detailed_view')
            .select('*')
            .contains('specializationids', [specializationId]);

        if (wilayaId != null) {
          query = query.eq('wilayas->>wilayaid', wilayaId.toString());
        }



        final response = await query;

        return (response as List)
            .map((json) => Artisan.fromJson(json))
            .toList();
      } catch (e) {
        return List<Artisan>.empty();
      }
    }



    Future<List<Specialization>> getSpecializations() async {
      try {
        if (_cachedSpecializations.isNotEmpty ) return _cachedSpecializations;
        final response = await supabase
            .from('specializations')
            .select()
            .order('name', ascending: true);

        _cachedSpecializations = response.map((e) => Specialization.fromJson(e)).toList();
        return _cachedSpecializations;
      } catch (e) {
        return  List<Specialization>.empty();
      }
    }

    Future<bool> updateArtisanProfile(Artisan updatedArtisan) async {
      try {

        Map<String, dynamic> updateData   = {
          'fullname': updatedArtisan.fullName,
          'phone': updatedArtisan.phone,
          'bio': updatedArtisan.bio,
          'profileimage':updatedArtisan.profileImage,
          'latitude': updatedArtisan.latitude,
          'longitude': updatedArtisan.longitude,
           'wilayaid':updatedArtisan.wilaya.wilayaId,
        };

        await supabase.from('artisans')
            .update(updateData)
            .eq('artisanid', updatedArtisan.artisanId);

        return true;
      } catch (e) {
        return false;
      }
    }

    Future<bool> verifyCurrentPassword(String? email, String currentPassword) async {
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: currentPassword,
        );

        if (response.session != null) {
          return true;
        } else {
          return false;
        }
      } catch (error) {
        return false;
      }
    }


    Future<bool> changePasswordWithCode({
      required String email,
      required String code,
      required String newPassword,
    }) async {



      final tempLogin = await supabase.auth.signInWithPassword(
        email: email,
        password: code,
      );

      if (tempLogin.session == null) {
        return false;
      }

      // 3. تغيير كلمة المرور للمستخدم الحالي
      final updateResponse = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (updateResponse.user == null) {
        return false;
      }

      // 4. حذف الكود بعد الاستخدام
      await supabase
          .from('passwordresets')
          .delete()
          .eq('email', email);

      return true;
    }



    Future<bool> changePassword(String? email,String newPassword) async {
      try {
        final response = await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            password: newPassword,
          ),
        );


        return response.user != null;
      } catch (error) {
        return false;
      }
    }


    Future<ArtisanImage?> addImageToArtisan(String imageUrl,int artisanId) async
    {

      try
      {
        final result = await supabase.from('artisanimages').insert({
          'artisanid': artisanId,
          'imageurl': imageUrl,
        }).select().single();

        ArtisanImage artisanImage = ArtisanImage.fromJson(result);

        return artisanImage;
      }
      catch(e)
      {
         return null;
      }

    }

    Future<bool> removeImageArtisan(String imageUrl,int artisanId) async
    {

      try
      {
        final result = await supabase.from('artisanimages').delete()
            .eq('imageurl', imageUrl)
            .eq('artisanid', artisanId);

        return true;
      }catch(e)
      {
        return false;
      }

    }

    Future<ArtisanSpecialization?> addSpecializationToArtisan(int specializationid,int artisanId) async
    {

      try
      {
        final result = await supabase.from('artisanspecializations').insert({
          'artisanid': artisanId,
          'specializationid': specializationid,
        }).select().single();

        ArtisanSpecialization artisanSpecialization = ArtisanSpecialization.fromJson(result);

        return artisanSpecialization;
      }
      catch(e)
      {
        return null;
      }

    }

    Future<bool> removeSpecializationArtisan(int specializationid,int artisanId) async
    {

      try
      {
        final result = await supabase.from('artisanspecializations').delete()
            .eq('specializationid', specializationid)
            .eq('artisanid', artisanId);

        return true;
      }catch(e)
      {
        return false;
      }

    }

    Future<void> saveVerificationOTPCode(String email, String code) async {
      await Supabase.instance.client
          .from('passwordresets')
          .upsert({'email': email, 'code': code});

    }
    Future<bool> verifyOTPCode(String email, String code) async {
      final response = await Supabase.instance.client
          .from('passwordresets')
          .select('code')
          .eq('email', email)
          .single();

      return response['code'] == code;
    }


}
