import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSizes.m),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
