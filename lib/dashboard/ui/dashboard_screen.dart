import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget? _selectedPage = const CategoryListScreen();
  int _selectedIndex = 0;

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
        largeScreen: Row(
          children: [
            Expanded(
              flex: ResponsiveWidget.isMediumScreen(context) ? 3 : 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Admin Panel',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMenuItem2(
                          context,
                          title: 'Categories',
                          icon: Icons.category,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 0;
                              _selectedPage = const CategoryListScreen();
                            });
                          },
                          isSelected: _selectedIndex == 0,
                        ),
                        _buildMenuItem2(
                          context,
                          title: 'Brands',
                          icon: Icons.branding_watermark,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 1;
                              _selectedPage = const BrandListScreen();
                            });
                          },
                          isSelected: _selectedIndex == 1,
                        ),
                        _buildMenuItem2(
                          context,
                          title: 'Products',
                          icon: Icons.shopping_basket,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 2;
                              _selectedPage = const CategoryScreen();
                            });
                          },
                          isSelected: _selectedIndex == 2,
                        ),
                        _buildMenuItem2(
                          context,
                          title: 'Stock',
                          icon: Icons.dataset,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 3;
                              _selectedPage = const ProductStockScreen();
                            });
                          },
                          isSelected: _selectedIndex == 3,
                        ),
                        _buildMenuItem2(
                          context,
                          title: 'Orders',
                          icon: Icons.list_alt,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 4;
                              _selectedPage = const OrderScreen();
                            });
                          },
                          isSelected: _selectedIndex == 4,
                        ),
                        _buildMenuItem2(
                          context,
                          title: 'Customers',
                          icon: Icons.supervised_user_circle_sharp,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 5;
                              _selectedPage = const CustomerScreen();
                            });
                          },
                          isSelected: _selectedIndex == 5,
                        ),
                        _buildMenuItem2(
                          context,
                          title: 'Payment Info',
                          icon: Icons.payments,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 6;
                              _selectedPage = const PaymentInfoScreen();
                            });
                          },
                          isSelected: _selectedIndex == 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right side where the selected page is displayed
            Expanded(
              flex: 6,
              child: _selectedPage != null
                  ? _selectedPage!
                  : const Center(
                      child: Text(
                        'Select an item from the menu',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
            ),
          ],
        ),
        smallScreen: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  const SizedBox(height: 24,),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Version ${snapshot.data!.version}(${snapshot.data!.buildNumber})',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32.0, color: Theme.of(context).primaryColor),
                const SizedBox(height: 8.0),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem2(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Function() onPressed,
    required bool isSelected, // Default background color
  }) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        color: isSelected
            ? Colors.blueAccent // Highlighted background color
            : Colors.blueGrey, // Set background color
        // elevation: 4.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, size: 28.0, color: Colors.white),
              const SizedBox(width: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Other screen classes like ProductScreen, ProductStockScreen, OrderScreen, CustomerScreen, PaymentInfoScreen, etc.
