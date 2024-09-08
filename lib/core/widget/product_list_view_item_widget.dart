import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/responsive_widget.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';
import 'package:sanitary_mart_admin/product/provider/product_provider.dart';
import 'package:sanitary_mart_admin/product/ui/screen/product_detail_screen.dart';

class ProductListViewItemWidget extends StatelessWidget {
  const ProductListViewItemWidget({
    required this.product,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Product product;
  final SlidableActionCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isMediumScreen = ResponsiveWidget.isMediumScreen(context);

    return Slidable(
        endActionPane: isMediumScreen
            ? null
            : ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      deleteProductDialog(context, product);
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: onPressed,
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                blurRadius: 2.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              Get.to(ProductDetailScreen(product: product));
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            contentPadding: const EdgeInsets.all(16.0),
            leading: SizedBox(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: NetworkImageWidget(
                  product.image ?? '',
                ),
              ),
            ),
            trailing: isMediumScreen
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            deleteProductDialog(context, product);
                          },
                          tooltip: 'Delete Product',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () => onPressed,
                          tooltip: 'Edit Product',
                        ),
                      ),
                    ],
                  )
                : null,
            title: Text(
              'Name: ${product.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price: ₹${product.price}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Available Stock: ${product.stock}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void deleteProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert '),
        content: Text("Delete ${product.name} product ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
              onPressed: () async {
                await deleteProduct(context, product);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Yes')),
        ],
      ),
    );
  }

  Future<void> deleteProduct(BuildContext context, Product product) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .deleteProduct(product.id!);
  }
}
