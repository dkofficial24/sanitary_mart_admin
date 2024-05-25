import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sanitary_mart_admin/core/widget/image_placeholder_widget.dart';


class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget(this.url,
      {this.width = 30, this.height = 30,this.imgHeight=150, super.key});

  final String url;
  final double height;
  final double width;
  final double imgHeight;

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => Center(
          child: SizedBox(
              width: width,
              height: height,
              child: const CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => const ImagePlaceHolder(),
        // Assuming you have imageUrl in your Product model
        fit: BoxFit.cover,
        height: imgHeight,
        width: double.infinity,
      );
    } else {
      return const ImagePlaceHolder();
    }
  }
}
