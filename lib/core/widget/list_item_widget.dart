import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sanitary_mart_admin/core/widget/app_image_network_widget.dart';

class ListItemWidget extends StatelessWidget {
  const ListItemWidget(
      {required this.name,
      required this.onDeleteCallback,
      required this.onEditCallback,
      this.onTapCallback,
      this.imagePath,
      super.key});

  final String name;
  final Function onDeleteCallback;
  final Function onEditCallback;
  final String? imagePath;
  final GestureTapCallback? onTapCallback;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              onDeleteCallback();
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTapCallback,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: NetworkImageWidget(
                      imagePath ?? '',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),

                Expanded(
                  flex: 2,
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      // Slightly larger font for better visibility
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Spacing between text and buttons
                const SizedBox(width: 16.0),

                // Action Buttons
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          // Light blue background
                          shape: BoxShape.circle, // Circular shape
                        ),
                        child: IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.blue, // Icon color
                            onPressed: () => onEditCallback()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
