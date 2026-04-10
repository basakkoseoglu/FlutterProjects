import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Kitap kapağı resmi — resim yoksa ya da yüklenemezse
/// aynı boyut ve düzende güzel bir placeholder gösterir.
class BookCoverWidget extends StatelessWidget {
  final String coverUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const BookCoverWidget({
    Key? key,
    required this.coverUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  // Kitap sayfasına hangi renk tonunu vereceğimizi başlıktan belirle
  static List<Color> _placeholderGradient(String url) {
    // URL hash'ine göre farklı renk tonları (deterministik ama çeşitli)
    final palettes = [
      [const Color(0xFF6C63FF), const Color(0xFF3B1FA8)], // mor
      [const Color(0xFFFF6B6B), const Color(0xFFCC2936)], // kırmızı
      [const Color(0xFF43AA8B), const Color(0xFF1A6B55)], // yeşil
      [const Color(0xFFFF9F43), const Color(0xFFCC6A00)], // turuncu
      [const Color(0xFF54A0FF), const Color(0xFF1E6FCC)], // mavi
      [const Color(0xFFE056FD), const Color(0xFF8B00CC)], // pembe-mor
      [const Color(0xFF00D2D3), const Color(0xFF007B7C)], // cyan
      [const Color(0xFFFF6348), const Color(0xFF9B1B0A)], // koyu turuncu
    ];
    final index = url.length % palettes.length;
    return palettes[index];
  }

  bool get _hasValidUrl =>
      coverUrl.isNotEmpty &&
      coverUrl.startsWith('http') &&
      !coverUrl.contains('placeholder');

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(0);

    Widget placeholder() {
      final colors = _placeholderGradient(coverUrl);
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.bookOpen,
              color: Colors.white.withValues(alpha: 0.85),
              size: _iconSize,
            ),
            if (_showLabel) ...[
              const SizedBox(height: 4),
              Text(
                'Kapak Yok',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]
          ],
        ),
      );
    }

    if (!_hasValidUrl) {
      return ClipRRect(borderRadius: radius, child: placeholder());
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        coverUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          // Yüklenirken placeholder göster (geçiş çok daha temiz)
          return placeholder();
        },
      ),
    );
  }

  double get _iconSize {
    final h = height ?? 100;
    if (h < 60) return 18;
    if (h < 100) return 24;
    return 36;
  }

  bool get _showLabel {
    final h = height ?? 100;
    return h >= 80;
  }
}
