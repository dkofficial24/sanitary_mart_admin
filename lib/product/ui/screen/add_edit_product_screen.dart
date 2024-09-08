import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';
import 'package:sanitary_mart_admin/product/provider/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? initialProduct;

  const AddEditProductScreen({Key? key, this.initialProduct}) : super(key: key);

  @override
  AddEditProductScreenState createState() => AddEditProductScreenState();
}

class AddEditProductScreenState extends State<AddEditProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController stockQuantityController = TextEditingController();
  final TextEditingController percentDiscountController =
      TextEditingController(text: '');
  final TextEditingController discountAmountController =
      TextEditingController(text: '');
  File? _image;

  DiscountType? _discountType =
      DiscountType.percentage; // Default to percentage

  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;

  Category? selectedCategory;
  Brand? selectedBrand;

  @override
  void initState() {
    init();
    super.initState();
  }

  void initEditProduct() {
    FirebaseAnalytics.instance.logEvent(name: 'open_product_editing');
    isEditing = true;
    final product = widget.initialProduct!;
    nameController.text = product.name;
    priceController.text = product.price.toString();
    descriptionController.text = product.description;
    stockQuantityController.text = product.stock.toString();
    if (product.discountAmount != null && product.discountAmount != 0) {
      discountAmountController.text = product.discountAmount.toString();
      _discountType = DiscountType.amount;
    } else if (product.discountPercentage != null) {
      _discountType = DiscountType.percentage;
      percentDiscountController.text = (product.discountPercentage != 0)
          ? product.discountPercentage.toString()
          : '';
    }

    print("ImagePath ->> ${widget.initialProduct!.image}");
  }

  Future init() async {
    if (widget.initialProduct != null) {
      initEditProduct(); // Assuming 'image' is a file path
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        fetchBrandAndCategory(
          widget.initialProduct!.categoryId,
          widget.initialProduct!.brandId,
        );
      });
    } else {
      FirebaseAnalytics.instance.logEvent(name: 'open_product_add');
    }
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Update Product' : 'Add Product',
      ),
      body: Consumer<ProductProvider>(
        builder: (BuildContext context, ProductProvider productProvider,
            Widget? child) {
          return Consumer<CategoryProvider>(
            builder: (BuildContext context, CategoryProvider categoryProvider,
                Widget? child) {
              return Consumer<BrandProvider>(builder: (BuildContext context,
                  BrandProvider brandProvider, Widget? child) {
                return formBody(
                  context,
                  productProvider: productProvider,
                  brandProvider: brandProvider,
                  categoryProvider: categoryProvider,
                );
              });
            },
          );
        },
      ),
    );
  }

  Widget formBody(
    BuildContext context, {
    required ProductProvider productProvider,
    required BrandProvider brandProvider,
    required CategoryProvider categoryProvider,
  }) {
    if (productProvider.state == ProviderState.loading ||
        brandProvider.state == ProviderState.loading ||
        categoryProvider.state == ProviderState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (productProvider.error ||
        brandProvider.state == ProviderState.error ||
        categoryProvider.state == ProviderState.error) {
      return ErrorRetryWidget(
        onRetry: () {
          if (productProvider.error) {
            _addEditProduct(context);
          }
          if (categoryProvider.error != null) {
            fetchCategories();
          }
          if (brandProvider.error != null) {
            fetchBrands();
          }
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              productImageSection(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: getImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      title: const Text('Percent'),
                      leading: Radio<DiscountType>(
                        value: DiscountType.percentage,
                        groupValue: _discountType,
                        onChanged: (DiscountType? value) {
                          setState(() {
                            _discountType = value;
                            discountAmountController
                                .clear(); // Clear the other field
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Amount'),
                      leading: Radio<DiscountType>(
                        value: DiscountType.amount,
                        groupValue: _discountType,
                        onChanged: (DiscountType? value) {
                          setState(() {
                            _discountType = value;
                            percentDiscountController
                                .clear(); // Clear the other field
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

// Conditional input field for Discount Percentage or Amount
              if (_discountType == DiscountType.percentage)
                TextFormField(
                  controller: percentDiscountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount Percentage',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_discountType == DiscountType.percentage &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter discount percentage';
                    }
                    return null;
                  },
                ),
              if (_discountType == DiscountType.amount)
                TextFormField(
                  controller: discountAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (_discountType == DiscountType.amount &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter discount amount';
                    }

                    double discount = double.tryParse(value.toString()) ?? 0;
                    final double price =
                        double.tryParse(priceController.text) ??
                            double.infinity;
                    if (discount > price) {
                      return 'Discount can not be more than product price';
                    }

                    return null;
                  },
                ),

              const SizedBox(height: 10),
              TextFormField(
                controller: stockQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButton<Category>(
                value: selectedCategory,
                onChanged: (Category? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: getCategoryProvider(context)
                    .categoryList
                    .map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                hint: const Text('Select Category'),
              ),
              const SizedBox(height: 10),
              DropdownButton<Brand>(
                value: selectedBrand,
                onChanged: (Brand? newValue) {
                  setState(() {
                    selectedBrand = newValue!;
                  });
                },
                items: getBrandProvider(context).brandList.map((Brand brand) {
                  return DropdownMenuItem<Brand>(
                    value: brand,
                    child: Text(brand.name),
                  );
                }).toList(),
                hint: const Text('Select Brand'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _addEditProduct(context);
                },
                child: Text(isEditing ? 'Update Product' : 'Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BrandProvider getBrandProvider(BuildContext context) =>
      Provider.of<BrandProvider>(context);

  CategoryProvider getCategoryProvider(BuildContext context) =>
      Provider.of<CategoryProvider>(context);

  ProductProvider getProductProvider(BuildContext context) =>
      Provider.of<ProductProvider>(context, listen: false);

  Widget productImageSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _image == null
          ? isEditing
              ? NetworkImageWidget(widget.initialProduct!.image ?? '')
              : const Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
          : Image.file(_image!, fit: BoxFit.cover),
    );
  }

  void _addEditProduct(BuildContext context) {
    if (true || _formKey.currentState!.validate()) {
      // if (isImageAvailable()) {
      final String name = nameController.text;
      final double price = double.tryParse(priceController.text) ?? 0;
      final String description = descriptionController.text;

      if (selectedCategory != null && selectedBrand != null) {
        double discountAmount = 0;
        double discountPercentage = 0;
        if (_discountType == DiscountType.amount) {
          discountAmount = double.tryParse(discountAmountController.text) ?? 0;
        } else {
          double percent = double.tryParse(percentDiscountController.text) ?? 0;
          discountPercentage = percent;
        }

        if (discountAmount > price) {
          AppUtil.showToast('Discount amount can not be more than the price');
          return;
        }
        if (discountPercentage > 100) {
          AppUtil.showToast('Discount percentage can not be more than 100%');
          return;
        }

        final Product newProduct = Product(
          id: widget.initialProduct?.id,
          name: name,
          price: price,
          description: description,
          discountAmount: discountAmount,
          discountPercentage: discountPercentage,
          stock: int.tryParse(stockQuantityController.text) ?? 1,
          categoryId: selectedCategory!.id!,
          brandId: selectedBrand!.id!,
          image: isEditing
              ? _image?.path ?? widget.initialProduct!.image
              : _image?.path,
        );
        final provider = getProductProvider(context);
        if (isEditing) {
          newProduct.created = widget.initialProduct?.created;
          newProduct.modified = DateTime.now().millisecondsSinceEpoch;
          provider.updateProduct(newProduct);
        } else {
          newProduct.created = DateTime.now().millisecondsSinceEpoch;
          provider.addProduct(newProduct);
        }
      } else {
        AppUtil.showToast('Product brand or category is missing');
      }
    }
    // else {
    //   AppUtil.showToast('Product image is not selected');
    // }
  }

  bool isImageAvailable() {
    //todo
    return isEditing || (_image?.existsSync() ?? false);
  }

  Future fetchBrandAndCategory(String categoryId, String brandId) async {
    CategoryProvider categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    BrandProvider brandProvider =
        Provider.of<BrandProvider>(context, listen: false);

    final result = await Future.wait([
      categoryProvider.fetchCategoryById(categoryId),
      brandProvider.fetchBrandById(brandId)
    ]);

    selectedCategory = result.isNotEmpty ? result[0] as Category? : null;
    selectedBrand = result.length > 1 ? result[1] as Brand? : null;
    if (mounted) setState(() {});

    FirebaseAnalytics.instance.logEvent(name: 'fetch_brand_and_category');
  }

  Future<void> fetchCategories() async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.fetchCategories();
  }

  Future fetchBrands() async {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    brandProvider.fetchBrands();
  }
}
