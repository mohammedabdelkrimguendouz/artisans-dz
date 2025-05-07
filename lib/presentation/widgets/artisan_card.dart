import 'package:artisans_dz/core/constants/spacing.dart';
import 'package:flutter/material.dart';
import '../../data/models/artisan_model.dart';
import '../../core/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtisanCard extends StatefulWidget {
  final Artisan artisan;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const ArtisanCard({
    super.key,
    required this.artisan,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<ArtisanCard> createState() => _ArtisanCardState();
}

class _ArtisanCardState extends State<ArtisanCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovering ? _scaleAnimation.value : 1.0,
              child: child,
            );
          },
          child: _buildCard(context),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: _isHovering || widget.isHighlighted
                ? colorScheme.primary.withOpacity(0.25)
                : Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: widget.isHighlighted
            ? colorScheme.primary.withOpacity(0.05)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(
                color: _isHovering || widget.isHighlighted
                    ? colorScheme.primary.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImage(),
                const SizedBox(width: 16),
                Expanded(child: _buildDetails(colorScheme)),
                _buildActionButton(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Hero(
      tag: 'artisan-image-${widget.artisan.artisanId}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _isHovering || widget.isHighlighted
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: _isHovering || widget.isHighlighted
                ? AppColors.primary
                : Colors.white,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.artisan.profileImage ?? '',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[100],
            ),
            errorWidget: (context, url, error) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[100],
              child: Image.asset(
                'assets/login.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.artisan.fullName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),

        // المنطقة
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 14,
              color: AppColors.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              widget.artisan.wilaya.name,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        if (widget.artisan.bio != null && widget.artisan.bio!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.artisan.bio!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],

        if (widget.artisan.specializations.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSpecializations(),
        ],
      ],
    );
  }

  Widget _buildSpecializations() {
    final visibleSpecializations = widget.artisan.specializations.length > 3
        ? widget.artisan.specializations.sublist(0, 3)
        : widget.artisan.specializations;

    final extraCount = widget.artisan.specializations.length - visibleSpecializations.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...visibleSpecializations.map((spec) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovering || widget.isHighlighted
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            spec.name,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: _isHovering || widget.isHighlighted
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
        )),
        // عرض العدد الإضافي إذا وجد
        if (extraCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '+$extraCount',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme) {
    return AnimatedOpacity(
      opacity: _isHovering ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovering ? AppColors.primary : AppColors.transparent,
          border: Border.all(
            color: _isHovering ? Colors.transparent : colorScheme.primary,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.arrow_forward,
          size: 18,
          color: _isHovering ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }
}

// بطاقة قائمة الحرفيين مع تأثيرات الظهور المتتالية
class ArtisansListView extends StatefulWidget {
  final List<Artisan> artisans;
  final Function(Artisan) onArtisanTap;

  const ArtisansListView({
    super.key,
    required this.artisans,
    required this.onArtisanTap,
  });

  @override
  State<ArtisansListView> createState() => _ArtisansListViewState();
}

class _ArtisansListViewState extends State<ArtisansListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: widget.artisans.length,
      itemBuilder: (context, index) {
        final artisan = widget.artisans[index];
        // تأخير متدرج لتأثير الظهور المتتالي
        return AnimatedAppearance(
          delay: Duration(milliseconds: 100 * index),
          child: ArtisanCard(
            artisan: artisan,
            onTap: () => widget.onArtisanTap(artisan),
          ),
        );
      },
    );
  }
}

// نموذج للتأثيرات الحركية عند ظهور العناصر
class AnimatedAppearance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AnimatedAppearance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedAppearance> createState() => _AnimatedAppearanceState();
}

class _AnimatedAppearanceState extends State<AnimatedAppearance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}