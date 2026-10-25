import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable loading state view with indicator and optional text.
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({
    super.key,
    this.message = 'Etkinlikler yükleniyor...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
              strokeWidth: 2.5,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable error state view with an icon, descriptive message, and a retry button.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryButtonText;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryButtonText = 'Tekrar Dene',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bir Sorun Oluştu',
              style: AppTypography.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(retryButtonText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable empty list state view with a friendly message.
class EmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionButtonText;

  const EmptyView({
    super.key,
    this.title = 'Etkinlik Bulunamadı',
    this.message = 'Şu anda gösterilecek bir etkinlik bulunmuyor.',
    this.icon = Icons.event_busy_rounded,
    this.onAction,
    this.actionButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            if (onAction != null && actionButtonText != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionButtonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
