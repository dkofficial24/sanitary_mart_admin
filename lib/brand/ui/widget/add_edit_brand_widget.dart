import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/core/provider_state.dart';
import 'package:sanitary_mart_admin/core/widget/app_image_network_widget.dart';
import 'package:sanitary_mart_admin/core/widget/responsive_widget.dart';

class AddEditBrandWidget extends StatefulWidget {
  const AddEditBrandWidget(
      {required this.onAction,
      required this.actionButtonName,
      this.brand,
      super.key});

  final Function(Brand brand) onAction;
  final String actionButtonName;
  final Brand? brand;

  @override
  State<AddEditBrandWidget> createState() => _AddEditBrandWidgetState();
}

class _AddEditBrandWidgetState extends State<AddEditBrandWidget> {
  final TextEditingController _nameController = TextEditingController();
  File? file;

  @override
  void initState() {
    _nameController.text = widget.brand?.name ?? '';

    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: Consumer<BrandProvider>(
        builder: (BuildContext context, BrandProvider provider, Widget? child) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
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
                                  : (widget.brand?.imagePath != null)
                                      ? NetworkImageWidget(
                                          widget.brand?.imagePath ?? '')
                                      : const SizedBox(),
                            ),
                          ),
                          TextFormField(
                            controller: _nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a brand name';
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
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  widget.onAction(Brand(
                                    name: _nameController.text,
                                    imagePath:
                                        file?.path ?? widget.brand?.imagePath,
                                  ));
                                }
                              },
                              child: Text(widget.actionButtonName))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Consumer<BrandProvider>(
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
      ),
      smallScreen: Consumer<BrandProvider>(
        builder: (BuildContext context, BrandProvider provider, Widget? child) {
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
                              : (widget.brand?.imagePath != null)
                                  ? NetworkImageWidget(
                                      widget.brand?.imagePath ?? '')
                                  : const SizedBox(),
                        ),
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a brand name';
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
                              widget.onAction(Brand(
                                name: _nameController.text,
                                imagePath:
                                    file?.path ?? widget.brand?.imagePath,
                              ));
                            }
                          },
                          child: Text(widget.actionButtonName))
                    ],
                  ),
                ),
              ),
              Consumer<BrandProvider>(
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
      ),
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
