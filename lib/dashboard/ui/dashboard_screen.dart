import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/ui/screen/brand_list_screen.dart';
import 'package:sanitary_mart_admin/category/ui/screen/category_list_screen.dart';
import 'package:sanitary_mart_admin/category/ui/screen/category_screen.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/responsive_widget.dart';
import 'package:sanitary_mart_admin/customer/ui/customer_screen.dart';
import 'package:sanitary_mart_admin/notification/provider/notification_provider.dart';
import 'package:sanitary_mart_admin/notification/screen/notification_screen.dart';
import 'package:sanitary_mart_admin/order/ui/order_screen.dart';
import 'package:sanitary_mart_admin/payment/ui/payment_info_screen.dart';
import 'package:sanitary_mart_admin/product/ui/stock_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        actions: [
          StreamBuilder<int>(
            stream: Provider.of<NotificationProvider>(context, listen: false)
                .getUnreadNotificationCountStream(),
            builder: (context, snapshot) {
              int unreadCount = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: ResponsiveWidget(
        largeScreen: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Admin Panel',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount:
                ResponsiveWidget.isMediumScreen(context) ? 5 : 8,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                children: [
                  _buildMenuItem(
                    context,
                    title: 'Categories',
                    icon: Icons.category,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryListScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Brands',
                    icon: Icons.branding_watermark,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BrandListScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Products',
                    icon: Icons.shopping_basket,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Stock',
                    icon: Icons.dataset,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductStockScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Orders',
                    icon: Icons.list_alt,
                    onPressed: () => Get.to(const OrderScreen()),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Customers',
                    icon: Icons.supervised_user_circle_sharp,
                    onPressed: () => Get.to(const CustomerScreen()),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Payment Info',
                    icon: Icons.payments,
                    onPressed: () => Get.to(const PaymentInfoScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
        smallScreen: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Admin Panel',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                children: [
                  _buildMenuItem(
                    context,
                    title: 'Categories',
                    icon: Icons.category,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryListScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Brands',
                    icon: Icons.branding_watermark,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BrandListScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Products',
                    icon: Icons.shopping_basket,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Stock',
                    icon: Icons.dataset,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductStockScreen(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Orders',
                    icon: Icons.list_alt,
                    onPressed: () => Get.to(const OrderScreen()),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Customers',
                    icon: Icons.supervised_user_circle_sharp,
                    onPressed: () => Get.to(const CustomerScreen()),
                  ),
                  _buildMenuItem(
                    context,
                    title: 'Payment Info',
                    icon: Icons.payments,
                    onPressed: () => Get.to(const PaymentInfoScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Function() onPressed,
      }) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 100,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32.0, color: Theme.of(context).primaryColor),
                const SizedBox(height: 8.0),
                Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
