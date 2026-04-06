import 'package:flutter/material.dart';

class PlatformFilePreview extends StatelessWidget {
  final String path;
  final double? height;

  const PlatformFilePreview({super.key, required this.path, this.height});

  bool _isNetworkLike(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('blob:') ||
        value.startsWith('data:');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isNetworkLike(path)) {
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey.shade500,
          size: 36,
        ),
      );
    }

    return Image.network(
      path,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade500,
            size: 36,
          ),
        );
      },
    );
  }
}
