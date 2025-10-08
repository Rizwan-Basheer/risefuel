import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_text_styles.dart';
import '../../data/models/quote_model.dart';
import '../../viewmodel/quotes_viewmodel.dart';
import '../widgets/favorite_button.dart';
import '../widgets/quote_card.dart';
import 'about_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuotesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_selectedIndex)),
        actions: <Widget>[
          IconButton(
            tooltip: _themeTooltip(viewModel.themeMode),
            onPressed: viewModel.toggleThemeMode,
            icon: Icon(_themeIcon(viewModel.themeMode)),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _buildBody(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            label: 'Favorites',
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
          ),
          NavigationDestination(
            label: 'About',
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    const pages = <Widget>[
      _DailyQuoteView(),
      FavoritesScreen(),
      AboutScreen(),
    ];
    final safeIndex = index.clamp(0, pages.length - 1);
    return pages[safeIndex];
  }

  String _titleForIndex(int index) {
    const titles = <String>['Daily Quotes', 'Favorites', 'About'];
    final safeIndex = index.clamp(0, titles.length - 1);
    return titles[safeIndex];
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => Icons.dark_mode,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.system => Icons.brightness_auto,
      };

  String _themeTooltip(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => 'Switch to light mode',
        ThemeMode.light => 'Use dark mode',
        ThemeMode.system => 'Toggle theme',
      };
}

class _DailyQuoteView extends StatelessWidget {
  const _DailyQuoteView();

  @override
  Widget build(BuildContext context) {
    return Consumer<QuotesViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return _ErrorState(
            message: viewModel.error!,
            onRetry: () => viewModel.initialize(forceRefresh: true),
          );
        }

        final quote = viewModel.currentQuote;
        if (quote == null) {
          return const _ErrorState(
            message: 'No quote available right now.',
          );
        }

        final friendlyDate =
            viewModel.dateHelper.formatFriendly(DateTime.now());

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Quote of the Day',
                style: AppTextStyles.sectionTitle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                friendlyDate,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              QuoteCard(quote: quote),
              const SizedBox(height: 24),
              _QuoteActions(quote: quote),
            ],
          ),
        );
      },
    );
  }
}

class _QuoteActions extends StatelessWidget {
  const _QuoteActions({required this.quote});

  final QuoteModel quote;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuotesViewModel>();
    final isFavorite = viewModel.isFavorite(quote);

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FavoriteButton(
              isFavorite: isFavorite,
              onPressed: () => viewModel.toggleFavorite(quote),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              onPressed: () => viewModel.refreshQuote(),
              icon: const Icon(Icons.refresh),
              label: const Text('New Quote'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => _shareQuote(quote),
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Need inspiration later? Save your favourites or come back tomorrow for something new.',
          style: AppTextStyles.body(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _shareQuote(QuoteModel quote) {
    final text = '"${quote.text}" — ${quote.author}';
    Share.share(text, subject: 'Daily Quote');
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.sentiment_dissatisfied_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(context),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
