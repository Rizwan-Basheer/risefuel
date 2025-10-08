import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/quote_model.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
  });

  final QuoteModel quote;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.secondary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.format_quote,
            size: 36,
            color: Colors.white70,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Scrollbar(
                thumbVisibility: false,
                child: SingleChildScrollView(
                  key: ValueKey<String>(quote.text),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    quote.text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.quote(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${quote.author}',
              textAlign: TextAlign.right,
              style: AppTextStyles.author(context).copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
