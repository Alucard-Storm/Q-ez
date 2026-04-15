import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A widget that loads and caches network images using [CachedNetworkImage].
/// Falls back to a placeholder icon when the URL is null/empty or loading fails.
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return _buildFallback(context);
    }

    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? _buildLoadingPlaceholder(context),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildFallback(context),
    );

    if (borderRadius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.emoji_events,
        size: (height ?? 48) * 0.5,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}

/// A circular cached avatar image, commonly used for user profile pictures.
class CachedAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;

  const CachedAvatarImage({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return _buildFallbackAvatar(context);
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => _buildFallbackAvatar(context),
    );
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    final initial = fallbackText?.isNotEmpty == true
        ? fallbackText![0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
