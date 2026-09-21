import 'package:flutter/material.dart';
import '../core/widgets/app_loading.dart';
import '../core/widgets/app_error_widget.dart';

class DataStateView<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final T? data;
  final Widget Function()? loadingBuilder;
  final Widget Function(String error)? errorBuilder;
  final Widget Function()? emptyBuilder;
  final Widget Function(T data) successBuilder;
  final VoidCallback? onRetry;

  const DataStateView({
    super.key,
    required this.isLoading,
    this.error,
    this.data,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    required this.successBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingBuilder?.call() ??
          const Center(child: AppCircularProgressIndicator());
    }
    if (error != null) {
      return errorBuilder?.call(error!) ??
          Center(child: AppErrorWidget(message: error!, onRetry: onRetry));
    }
    if (data == null || (data is List && (data as List).isEmpty)) {
      return emptyBuilder?.call() ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          );
    }
    return successBuilder(data as T);
  }
}
