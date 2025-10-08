import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/date_helper.dart';
import '../data/local/quotes_local_data.dart';
import '../data/models/quote_model.dart';

class QuotesViewModel extends ChangeNotifier {
  QuotesViewModel({
    required this.localData,
    required this.sharedPreferences,
    required this.dateHelper,
  });

  final QuotesLocalData localData;
  final SharedPreferences sharedPreferences;
  final DateHelper dateHelper;

  static const String _favoritesKey = 'favorite_quotes_v1';
  static const String _lastQuoteIdKey = 'last_quote_id';
  static const String _lastQuoteDayKey = 'last_quote_day';
  static const String _themeModeKey = 'theme_mode';

  final Random _random = Random();

  List<QuoteModel> _quotes = <QuoteModel>[];
  QuoteModel? _currentQuote;
  Set<String> _favoriteIds = <String>{};
  bool _isLoading = true;
  String? _error;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isLoading => _isLoading;
  String? get error => _error;
  QuoteModel? get currentQuote => _currentQuote;
  ThemeMode get themeMode => _themeMode;
  List<QuoteModel> get favoriteQuotes =>
      _quotes.where((quote) => _favoriteIds.contains(quote.storageId)).toList();

  bool isFavorite(QuoteModel quote) => _favoriteIds.contains(quote.storageId);

  Future<void> initialize({bool forceRefresh = false}) async {
    if (_quotes.isNotEmpty && !forceRefresh) {
      return;
    }
    _setLoading(true);
    try {
      _quotes = await localData.loadQuotes();
      _favoriteIds =
          sharedPreferences.getStringList(_favoritesKey)?.toSet() ?? <String>{};
      _themeMode = _restoreThemeMode();

      final savedDay = sharedPreferences.getString(_lastQuoteDayKey);
      final savedQuoteId = sharedPreferences.getString(_lastQuoteIdKey);

      if (savedDay != null &&
          savedQuoteId != null &&
          dateHelper.isSameDayKey(savedDay)) {
        _currentQuote = _quotes.firstWhere(
          (quote) => quote.storageId == savedQuoteId,
          orElse: () => _pickRandomQuote(),
        );
      } else {
        _currentQuote = _pickRandomQuote();
        await _persistDailyQuote(_currentQuote!);
      }
      _error = null;
    } catch (_) {
      _error = 'Unable to load quotes. Please try again later.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshQuote() async {
    if (_quotes.isEmpty) {
      await initialize(forceRefresh: true);
      return;
    }
    final previousId = _currentQuote?.storageId;
    QuoteModel next = _pickRandomQuote();
    if (_quotes.length > 1) {
      for (int i = 0; i < 5 && next.storageId == previousId; i++) {
        next = _pickRandomQuote();
      }
    }
    _currentQuote = next;
    await _persistDailyQuote(next);
    notifyListeners();
  }

  void toggleFavorite(QuoteModel quote) {
    final id = quote.storageId;
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    _persistFavorites();
    notifyListeners();
  }

  void removeFavorite(QuoteModel quote) {
    if (_favoriteIds.remove(quote.storageId)) {
      _persistFavorites();
      notifyListeners();
    }
  }

  void toggleThemeMode() {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    sharedPreferences.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  ThemeMode _restoreThemeMode() {
    final stored = sharedPreferences.getString(_themeModeKey);
    if (stored == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  QuoteModel _pickRandomQuote() {
    if (_quotes.isEmpty) {
      return QuoteModel(text: 'No quotes available', author: 'Unknown');
    }
    return _quotes[_random.nextInt(_quotes.length)];
  }

  Future<void> _persistDailyQuote(QuoteModel quote) async {
    await sharedPreferences.setString(_lastQuoteIdKey, quote.storageId);
    await sharedPreferences.setString(
      _lastQuoteDayKey,
      dateHelper.dayKey(),
    );
  }

  Future<void> _persistFavorites() async {
    await sharedPreferences.setStringList(
      _favoritesKey,
      _favoriteIds.toList(),
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

