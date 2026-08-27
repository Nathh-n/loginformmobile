import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;

  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
        ),
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('ID: ${product.id}'),
      ),
    );
  }
}