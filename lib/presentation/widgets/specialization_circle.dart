import 'package:artisans_dz/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpecializationCircle extends StatefulWidget {
  final bool isSelected;
  final String imageUrl;
  final String name;
  final VoidCallback onTap;

  const SpecializationCircle({
    super.key,
    required this.isSelected,
    required this.imageUrl,
    required this.name,
    required this.onTap,
  });

  @override
  State<SpecializationCircle> createState() => _SpecializationCircleState();
}

class _SpecializationCircleState extends State<SpecializationCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SpecializationCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        widget.onTap();
        if (!widget.isSelected) {
          _controller.forward();
        }
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isSelected ? _scaleAnimation.value : 1.0,
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: widget.isSelected
                          ? [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                          : [],
                      border: Border.all(
                        color: widget.isSelected
                            ? AppColors.primary
                            : Colors.grey,
                        width: widget.isSelected ? _borderAnimation.value : 1.0,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: ClipOval(
                child: Hero(
                  tag: 'specialization_${widget.name}',
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, color: Colors.grey),
                    ),
                    cacheKey: 'specialization_${widget.imageUrl}',
                    memCacheWidth: 200,
                    memCacheHeight: 200,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: widget.isSelected ? AppColors.primary : Colors.black87,
                fontSize: 10,
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: SizedBox(
                height: 42,
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: widget.isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}