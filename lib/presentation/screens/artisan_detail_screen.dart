import 'package:artisans_dz/core/constants/colors.dart';
import 'package:artisans_dz/presentation/navigation/navigation_extension.dart';
import 'package:flutter/material.dart';
import '../../data/models/artisan_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../navigation/navigation_extension.dart';

class ArtisanDetailScreen extends StatefulWidget {
  final Artisan artisan;
  const ArtisanDetailScreen({super.key, required this.artisan});
  @override
  State<ArtisanDetailScreen> createState() => _ArtisanDetailScreenState();
}

class _ArtisanDetailScreenState extends State<ArtisanDetailScreen> with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  final GlobalKey _headerKey = GlobalKey();
  bool _showFloatingButton = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  void _onScroll() {
    if (_scrollController.offset > 300 && !_showFloatingButton) {
      setState(() => _showFloatingButton = true);
    } else if (_scrollController.offset <= 300 && _showFloatingButton) {
      setState(() => _showFloatingButton = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps() async {
    if (widget.artisan.latitude == null || widget.artisan.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا تتوفر معلومات الموقع')),
      );
      return;
    }

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.artisan.latitude},${widget.artisan.longitude}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'تعذر فتح خرائط جوجل';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن الاتصال بالرقم $phoneNumber')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: _buildDetails(theme),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 80),
            ),
          ],
        ),
        floatingActionButton: AnimatedOpacity(
          opacity: _showFloatingButton ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            backgroundColor: AppColors.primary, // إضافة لون أساسي للزر العائم
            child: const Icon(Icons.arrow_upward),
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
        bottomNavigationBar: _buildContactBar(theme),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary, // استخدام اللون الرئيسي بدلاً من theme.primaryColor
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Hero(
          tag: 'artisan-image-${widget.artisan.artisanId}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.artisan.profileImage ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: FadeTransition(
                  opacity: _animationController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.artisan.fullName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black45,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.artisan.wilaya.name,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.artisan.bio != null && widget.artisan.bio!.isNotEmpty)
            _buildAnimatedSection(
              title: 'نبذة عن الحرفي',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // تغيير اللون من AppColors.primary إلى أبيض
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1), // إضافة حدود باللون الرئيسي
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.artisan.bio!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),

          if (widget.artisan.specializations.isNotEmpty)
            _buildAnimatedSection(
              title: 'التخصصات',
              child: _buildSpecializations(theme),
              delay: 0.2,
            ),

          _buildAnimatedSection(
            title: 'معلومات الاتصال',
            child: _buildContactInfo(theme),
            delay: 0.3,
          ),

          if (widget.artisan.images.isNotEmpty)
            _buildAnimatedSection(
              title: 'معرض الأعمال',
              child: _buildGallery(theme),
              delay: 0.4,
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({
    required String title,
    required Widget child,
    double delay = 0.0,
  }) {
    final Animation<double> animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        delay,
        delay + 0.6,
        curve: Curves.easeOut,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(animation),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecializations(ThemeData theme) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.artisan.specializations.map((spec) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white, // تغيير اللون الخلفية من AppColors.primary إلى أبيض
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary,
              width: 1,
            ),
          ),
          child: Text(
            spec.name,
            style: TextStyle(
              color: AppColors.primary, // الإبقاء على اللون الرئيسي للنص
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            icon: Icons.location_on,
            iconColor: Colors.redAccent,
            text: widget.artisan.wilaya.name,
          ),
          if (widget.artisan.phone != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            _buildDetailRow(
              context,
              icon: Icons.phone,
              iconColor: Colors.green,
              text: widget.artisan.phone!,
            ),
          ],
          if (widget.artisan.latitude != null && widget.artisan.longitude != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            InkWell(
              onTap: _openGoogleMaps,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.map, size: 22, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الموقع على الخريطة',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'انقر لفتح في خرائط جوجل',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_left, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGallery(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              PageView.builder(
                itemCount: widget.artisan.images.length,
                onPageChanged: (index) {
                  setState(() => _selectedImageIndex = index);
                },
                itemBuilder: (context, index) {
                  final image = widget.artisan.images[index];
                  return GestureDetector(
                    onTap: () => _showFullImage(context, index), // تغيير لإرسال المؤشر بدلا من imageUrl
                    child: Hero(
                      tag: 'gallery-image-${image.artisanImageId}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: image.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.artisan.images.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _selectedImageIndex == index ? 16 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _selectedImageIndex == index
                            ? AppColors.primary // استخدام اللون الرئيسي
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.artisan.images.length,
            itemBuilder: (context, index) {
              final image = widget.artisan.images[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedImageIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedImageIndex == index
                          ? AppColors.primary // استخدام اللون الرئيسي
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: image.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        width: 70,
                        height: 70,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 30),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // تعديل لاستخدام index بدلاً من imageUrl لعرض الصورة الصحيحة
  void _showFullImage(BuildContext context, int index) {
    final String imageUrl = widget.artisan.images[index].imageUrl;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.9),
            child: Stack(
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 40,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor ?? Theme.of(context).iconTheme.color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child:
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () => _makePhoneCall(widget.artisan.phone!),
              icon: const Icon(Icons.phone, color: Colors.white),
              tooltip: 'اتصال',
            ),
          ),
      ),
    );
  }
}