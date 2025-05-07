import 'package:artisans_dz/core/constants/spacing.dart';
import 'package:artisans_dz/data/models/wilaya_model.dart';
import 'package:flutter/material.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/artisan_model.dart';
import '../widgets/artisan_card.dart';
import 'package:artisans_dz/presentation/screens/artisan_detail_screen.dart';
import 'package:artisans_dz/data/models/specialization_model.dart';
import 'package:artisans_dz/presentation/widgets/specialization_circle.dart';
import 'package:artisans_dz/core/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;


  final SupabaseService supabaseService = SupabaseService();
  List<Artisan> artisans = [];
  List<Specialization> specializations = [];
  int? selectedSpecializationId;
  bool isLoading = true;
  String? errorMessage;
  late List<Wilaya> wilayas = List<Wilaya>.empty();
  Wilaya? selectedWilaya;

  // Animation controllers
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;


  // Cache for artisans by specialization
  //final Map<int, List<Artisan>> _artisanCache = {};

  @override
  void initState() {
    super.initState();
    getWilayas();
    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _loadSpecializations();
  }
  void getWilayas() async {
    final result = await SupabaseService().getWilayas();
    setState(() {
      wilayas = result;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSpecializations() async {
    try {
      final specs = await supabaseService.getSpecializations();

      setState(() {
        specializations = specs;
        isLoading = false;
      });
      if (specializations.isNotEmpty) {
        _filterArtisansBySpecializationAndWilaya(specializations.first.specializationId,null);
      }


      // Start animation after data is loaded
      _controller.forward();
    } catch (e) {
      setState(() {
        errorMessage = 'فشل في تحميل التخصصات: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _filterArtisansBySpecializationAndWilaya(int? specId,int? wilayaId) async {
    if (specId == null) return;



    setState(() {
      selectedSpecializationId = specId;
      isLoading = true;
    });

    try {

      final data = await supabaseService.getArtisansBySpecializationAndWilaya(specId,wilayaId);



      setState(() {
        artisans = data;
        isLoading = false;
      });

      // Restart animation
      _controller.reset();
      _controller.forward();
    } catch (e) {
      setState(() {
        errorMessage = 'فشل في جلب الحرفيين: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SafeArea(
          top: true,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && specializations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return Column(
      children: [
        _buildSpecializationsRow(),
        SizedBox(height: 10.0),
        _buildWilayaOption(),
        Expanded(
          child: _buildArtisansList(),
        ),
      ],
    );
  }

  Widget _buildSpecializationsRow() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specializations.length,
        itemBuilder: (context, index) {
          final spec = specializations[index];

          // Adding staggered animation for each specialization circle
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Calculate staggered delay based on index
              final double delay = index * 0.1;
              final double start = delay;
              final double end = start + 0.4;

              // Create a staggered animation interval
              final Animation<double> staggeredAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    start.clamp(0.0, 1.0),
                    end.clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                ),
              );

              return Transform.scale(
                scale: 0.8 + (0.2 * staggeredAnimation.value),
                child: Opacity(
                  opacity: staggeredAnimation.value,
                  child: child,
                ),
              );
            },
            child: SpecializationCircle(
              isSelected: selectedSpecializationId == spec.specializationId,
              imageUrl: spec.imageUrl,
              name: spec.name,
              onTap: () => _filterArtisansBySpecializationAndWilaya(spec.specializationId,selectedWilaya==null?null:  selectedWilaya!.wilayaId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtisansList() {
    if (isLoading && artisans.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (artisans.isEmpty) {
      return const Center(child: Text('لا يوجد حرفيين في هذا التخصص'));
    }

    return RefreshIndicator(
      onRefresh: () => _filterArtisansBySpecializationAndWilaya(selectedSpecializationId,selectedWilaya==null?null:  selectedWilaya!.wilayaId),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: artisans.length,
          itemBuilder: (context, index) {
            // Create staggered animation for each card
            final double delay = index * 0.05;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final Animation<double> itemAnimation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      delay.clamp(0.0, 1.0),
                      (delay + 0.5).clamp(0.0, 1.0),
                      curve: Curves.easeInOut,
                    ),
                  ),
                );

                return Opacity(
                  opacity: itemAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - itemAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: ArtisanCard(
                artisan: artisans[index],
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ArtisanDetailScreen(artisan: artisans[index]),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildWilayaOption() {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<Wilaya>(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_city),
          prefixIconColor: AppColors.primary,
          labelText: 'الولايات',
          hintText: 'اختر ولاية',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor:  AppColors.secondary,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        value:selectedWilaya,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        onChanged: (Wilaya? newValue) {
          setState(() {
            selectedWilaya = newValue;
            _filterArtisansBySpecializationAndWilaya(selectedSpecializationId,selectedWilaya==null?null: selectedWilaya!.wilayaId);

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
}