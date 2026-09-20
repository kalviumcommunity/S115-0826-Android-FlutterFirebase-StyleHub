import 'package:flutter/material.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

/// A generic wrapper that handles the 4 mandatory UI states:
/// Loading, Error, Empty, and Success.
class DataStateView<T> extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final T data;
  final bool isEmpty;
  final Widget Function(T data) successBuilder;
  final Widget Function(String error)? errorBuilder;
  final Widget Function()? emptyBuilder;
  final Widget Function()? loadingBuilder;

  const DataStateView({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.data,
    required this.isEmpty,
    required this.successBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Priority: Loading
    if (isLoading) {
      return loadingBuilder?.call() ??
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
    }

    // 2. Priority: Error
    if (errorMessage != null) {
      return errorBuilder?.call(errorMessage!) ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: AppSpacing.m),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSpacing.m),
              ElevatedButton(
                onPressed: () {
                  // Retry logic is usually handled by the parent calling
                  // a provider method.
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    }

    // 3. Priority: Empty
    if (isEmpty) {
      return emptyBuilder?.call() ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, color: AppColors.secondary, size: 48),
              const SizedBox(height: AppSpacing.m),
              Text(
                'No data found',
                style: AppTypography.titleMedium.copyWith(color: AppColors.onSurface),
              ),
            ],
          ),
        );
    }

    // 4. Priority: Success
    return successBuilder(data);
  }

}
