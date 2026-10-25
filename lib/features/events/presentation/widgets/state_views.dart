import 'package:flutter/material.dart';

/// Reusable loading state view with optional indicator text.
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
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
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
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 54,
            ),
            const SizedBox(height: 16),
            Text(
              'Bir Sorun Oluştu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
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
            Icon(
              icon,
              color: Colors.grey[400],
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
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
