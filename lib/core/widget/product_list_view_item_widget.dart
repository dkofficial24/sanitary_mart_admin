import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';
import 'package:sanitary_mart_admin/product/provider/product_provider.dart';
import 'package:sanitary_mart_admin/product/ui/screen/add_edit_product_screen.dart';
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
    return Slidable(
      endActionPane: ActionPane(
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
      child: ListTile(
        onTap: () {
          Get.to(ProductDetailScreen(product: product));
        },
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.all(12.0),
        leading: SizedBox(
          width: 80,
          height: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: NetworkImageWidget(
              product.image??'',
            ),
          ),
        ),
        trailing: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        title: Text(
          'Name: ${product.name}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${product.price}'),
            Text('Available Stock: ${product.stock}'),
          ],
        ),
      ),
    );
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
