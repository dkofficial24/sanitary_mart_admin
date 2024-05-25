import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorRetryWidget(
      {super.key,
      this.message = 'Something went wrong.',
      required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Icon(Icons.warning_amber_rounded,
              size: Get.height*0.1,color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                //color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Retry'),
                  SizedBox(width: 10),
                  Icon(Icons.refresh),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
