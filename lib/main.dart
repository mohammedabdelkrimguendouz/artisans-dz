import 'package:artisans_dz/data/models/artisan_model.dart';
import 'package:artisans_dz/presentation/navigation/navigation_extension.dart';
import 'package:artisans_dz/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:artisans_dz/presentation/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artisans_dz/env.env';
import 'package:artisans_dz/data/services/user_preferences.dart';


Future<String> getInitialRoute() async {
  Artisan? artisan = await UserPreferences.getArtisan();

  if (artisan != null) {
    return "/home_page";
  }

  return "/welcome_screen";
}


 void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  String initialRoute = await getInitialRoute();

  runApp(ArtisanApp(initialRoute: initialRoute));
}






class ArtisanApp extends StatelessWidget {
  final String initialRoute;
  const ArtisanApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل الحرفيين',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Cairo'),
      initialRoute: initialRoute,
      routes: {
        "/welcome_screen": (context) => WelcomeScreen(),
        "/home_page": (context) => HomePage(),
      },
    );
  }
}






