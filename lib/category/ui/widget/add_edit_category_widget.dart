import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/core/provider_state.dart';
import 'package:sanitary_mart_admin/core/widget/app_image_network_widget.dart';

class AddEditCategoryWidget extends StatefulWidget {
  const AddEditCategoryWidget(
      {required this.onAction,
      required this.actionButtonName,
      this.category,
      super.key});

  final Function(Category category) onAction;
  final String actionButtonName;
  final Category? category;

  @override
  State<AddEditCategoryWidget> createState() => _AddEditCategoryWidgetState();
}

class _AddEditCategoryWidgetState extends State<AddEditCategoryWidget> {
  final TextEditingController _nameController = TextEditingController();
  File? file;

  @override
  void initState() {
    _nameController.text = widget.category?.name ?? '';

    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
        return Stack(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    SizedBox(
                      height: 200.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: file != null
                            ? Stack(
                                children: [
                                  Image.file(file!),
                                  if (provider.imageUploading)
                                    const Align(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        )),
                                ],
                              )
                            : (widget.category?.imagePath != null)
                                ? NetworkImageWidget(
                                    widget.category?.imagePath ?? '')
                                : const SizedBox(),
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () async {
                              await pickImage(ImageSource.camera);
                            },
                            icon: const Icon(Icons.camera)),
                        IconButton(
                            onPressed: () async {
                              await pickImage(ImageSource.gallery);
                            },
                            icon: const Icon(Icons.image)),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            widget.onAction(Category(
                              name: _nameController.text,
                              imagePath:
                                  file?.path ?? widget.category?.imagePath,
                            ));
                          }
                        },
                        child: Text(widget.actionButtonName))
                  ],
                ),
              ),
            ),
            Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                if (provider.state == ProviderState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return const SizedBox();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> pickImage(ImageSource imageSource) async {
    XFile? xFile = await ImagePicker().pickImage(source: imageSource);
    if (xFile != null) {
      file = File(xFile.path);
    }
    setState(() {});
  }
}
