import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A dialog that reveals a newly created or regenerated token value.
///
/// Shows a warning that this is the only time the token will be visible,
/// displays the token in a monospace format with a copy button.
class TokenRevealDialog extends StatelessWidget {
  final String tokenValue;
  final String tokenName;

  const TokenRevealDialog({
    super.key,
    required this.tokenValue,
    required this.tokenName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadDialog(
      constraints: const BoxConstraints(maxWidth: 520),
      title: Text('Token Created: $tokenName'),
      actions: [
        ShadButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Warning banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.triangleAlert,
                  size: 16,
                  color: Colors.amber.shade300,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Copy the token below - this is your only chance to do so!',
                    style: theme.textTheme.small.copyWith(
                      color: Colors.amber.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Token display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    tokenValue,
                    style: theme.textTheme.small.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  leading: Icon(LucideIcons.copy, size: 14),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: tokenValue));
                    ShadToaster.of(context).show(
                      const ShadToast(
                        title: Text('Token copied to clipboard'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
