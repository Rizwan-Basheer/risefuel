import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/date_helper.dart';
import '../data/local/quotes_local_data.dart';
import '../data/models/quote_model.dart';
import '../data/remote/quotes_api.dart';

class QuotesViewModel extends ChangeNotifier {
  QuotesViewModel({
    required this.localData,
    required this.remoteData,
    required this.sharedPreferences,
    required this.dateHelper,
  });

  final QuotesLocalData localData;
  final QuotesApi remoteData;
  final SharedPreferences sharedPreferences;
  final DateHelper dateHelper;

  static const String _quotesCacheKey = 'cached_quotes_v1';
  static const String _quoteOfDayKey = 'cached_quote_of_day_v1';
  static const String _favoritesKey = 'favorite_quotes_v2';
  static const String _legacyFavoriteIdsKey = 'favorite_quotes_v1';
  static const String _lastFetchDayKey = 'last_fetch_day_v1';
  static const String _currentIndexKey = 'current_index_v1';
  static const String _themeModeKey = 'theme_mode';

  List<QuoteModel> _quotes = <QuoteModel>[];
  QuoteModel? _quoteOfDay;
  Map<String, QuoteModel> _favoriteQuotes = <String, QuoteModel>{};
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;
  ThemeMode _themeMode = ThemeMode.system;
  bool _hasInitialized = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ThemeMode get themeMode => _themeMode;
  List<QuoteModel> get quotes => List<QuoteModel>.unmodifiable(_quotes);
  QuoteModel? get quoteOfDay => _quoteOfDay;
  int get currentIndex => _currentIndex;
  QuoteModel? get currentQuote => _quotes.isEmpty
      ? null
      : _quotes[_currentIndex.clamp(0, _quotes.length - 1)];

  List<QuoteModel> get favoriteQuotes =>
      List<QuoteModel>.unmodifiable(_favoriteQuotes.values);

  bool isFavorite(QuoteModel quote) =>
      _favoriteQuotes.containsKey(quote.storageId);

  bool get canGoNext => _currentIndex < _quotes.length - 1;
  bool get canGoPrevious => _currentIndex > 0;

  Future<void> initialize({bool forceRefresh = false}) async {
    if (!_hasInitialized || forceRefresh) {
      await _restoreState();
      _hasInitialized = true;
    }
    if (forceRefresh || _shouldRefreshDaily()) {
      await fetchLatestQuotes(force: true);
    }
  }

  Future<void> _restoreState() async {
    _setLoading(true);
    try {
      await _restoreThemeMode();
      await _restoreCachedQuotes();
      await _restoreFavorites();

      _currentIndex =
          sharedPreferences.getInt(_currentIndexKey) ?? _currentIndex;
      _ensureCurrentIndexBounds();

      if (_quotes.isEmpty) {
        _quotes = await localData.loadQuotes();
      }
      _quoteOfDay ??= _quotes.isNotEmpty ? _quotes.first : null;
      _error = null;
    } catch (_) {
      if (_quotes.isEmpty) {
        _error =
            'Unable to load quotes. Please check your connection and try again.';
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchLatestQuotes({bool force = false}) async {
    if (!force && !_shouldRefreshDaily()) {
      return;
    }
    _setLoading(true);
    try {
      final QuoteModel? latestOfDay = await remoteData.fetchQuoteOfDay();
      final List<QuoteModel> fetchedQuotes = await remoteData.fetchQuotes();

      if (fetchedQuotes.isNotEmpty) {
        _quotes = fetchedQuotes;
      }
      if (latestOfDay != null) {
        _quoteOfDay = latestOfDay;
        final bool contains =
            _quotes.any((quote) => quote.storageId == latestOfDay.storageId);
        if (!contains) {
          _quotes = <QuoteModel>[latestOfDay, ..._quotes];
        }
      } else if (_quoteOfDay == null && _quotes.isNotEmpty) {
        _quoteOfDay = _quotes.first;
      }
      _currentIndex = 0;
      await _persistQuotes();
      await _persistQuoteOfDay();
      await _persistCurrentIndex();
      await sharedPreferences.setString(
        _lastFetchDayKey,
        dateHelper.dayKey(),
      );
      _error = null;
    } catch (_) {
      if (_quotes.isEmpty) {
        _error =
            'Unable to fetch quotes right now. Please try again later.';
      } else {
        _error ??=
            'Showing saved quotes. We could not contact the quotes service.';
      }
    } finally {
      _setLoading(false);
    }
  }

  void toggleFavorite(QuoteModel quote) {
    final id = quote.storageId;
    if (_favoriteQuotes.containsKey(id)) {
      _favoriteQuotes.remove(id);
    } else {
      _favoriteQuotes[id] = quote;
    }
    _persistFavorites();
    notifyListeners();
  }

  void removeFavorite(QuoteModel quote) {
    if (_favoriteQuotes.remove(quote.storageId) != null) {
      _persistFavorites();
      notifyListeners();
    }
  }

  void setCurrentIndex(int index) {
    if (_quotes.isEmpty) {
      return;
    }
    final int nextIndex = index.clamp(0, _quotes.length - 1);
    if (nextIndex == _currentIndex) {
      return;
    }
    _currentIndex = nextIndex;
    _persistCurrentIndex();
    notifyListeners();
  }

  void goToNextQuote() {
    if (canGoNext) {
      setCurrentIndex(_currentIndex + 1);
    }
  }

  void goToPreviousQuote() {
    if (canGoPrevious) {
      setCurrentIndex(_currentIndex - 1);
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

  bool _shouldRefreshDaily() {
    final String todayKey = dateHelper.dayKey();
    final String? stored = sharedPreferences.getString(_lastFetchDayKey);
    return stored == null || stored != todayKey;
  }

  Future<void> _restoreThemeMode() async {
    final stored = sharedPreferences.getString(_themeModeKey);
    if (stored == null) {
      _themeMode = ThemeMode.system;
      return;
    }
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> _restoreCachedQuotes() async {
    final String? storedQuotes = sharedPreferences.getString(_quotesCacheKey);
    if (storedQuotes != null && storedQuotes.isNotEmpty) {
      final dynamic data = jsonDecode(storedQuotes);
      if (data is List) {
        _quotes = data
            .whereType<Map<String, dynamic>>()
            .map(QuoteModel.fromJson)
            .toList();
      }
    }
    final String? storedQuoteOfDay =
        sharedPreferences.getString(_quoteOfDayKey);
    if (storedQuoteOfDay != null && storedQuoteOfDay.isNotEmpty) {
      final dynamic parsed = jsonDecode(storedQuoteOfDay);
      if (parsed is Map<String, dynamic>) {
        _quoteOfDay = QuoteModel.fromJson(parsed);
      }
    }
  }

  Future<void> _restoreFavorites() async {
    final String? storedFavorites =
        sharedPreferences.getString(_favoritesKey);
    if (storedFavorites != null && storedFavorites.isNotEmpty) {
      final dynamic data = jsonDecode(storedFavorites);
      if (data is List) {
        final Map<String, QuoteModel> stored = <String, QuoteModel>{};
        for (final Map<String, dynamic> item
            in data.whereType<Map<String, dynamic>>()) {
          final quote = QuoteModel.fromJson(item);
          stored[quote.storageId] = quote;
        }
        _favoriteQuotes = stored;
      }
      return;
    }

    final List<String>? legacyIds =
        sharedPreferences.getStringList(_legacyFavoriteIdsKey);
    if (legacyIds != null && legacyIds.isNotEmpty) {
      final Map<String, QuoteModel> migrated = <String, QuoteModel>{};
      for (final String id in legacyIds) {
        QuoteModel? match;
        for (final QuoteModel quote in _quotes) {
          if (quote.storageId == id) {
            match = quote;
            break;
          }
        }
        if (match != null) {
          migrated[id] = match;
        }
      }
      if (migrated.isNotEmpty) {
        _favoriteQuotes = migrated;
      }
      await _persistFavorites();
      await sharedPreferences.remove(_legacyFavoriteIdsKey);
    }
  }

  Future<void> _persistQuotes() async {
    if (_quotes.isEmpty) {
      await sharedPreferences.remove(_quotesCacheKey);
      return;
    }
    final encoded =
        jsonEncode(_quotes.map((quote) => quote.toJson()).toList());
    await sharedPreferences.setString(_quotesCacheKey, encoded);
  }

  Future<void> _persistQuoteOfDay() async {
    if (_quoteOfDay == null) {
      await sharedPreferences.remove(_quoteOfDayKey);
      return;
    }
    await sharedPreferences.setString(
      _quoteOfDayKey,
      jsonEncode(_quoteOfDay!.toJson()),
    );
  }

  Future<void> _persistFavorites() async {
    if (_favoriteQuotes.isEmpty) {
      await sharedPreferences.remove(_favoritesKey);
      return;
    }
    final encoded = jsonEncode(
      _favoriteQuotes.values.map((quote) => quote.toJson()).toList(),
    );
    await sharedPreferences.setString(_favoritesKey, encoded);
  }

  Future<void> _persistCurrentIndex() async {
    await sharedPreferences.setInt(_currentIndexKey, _currentIndex);
  }

  void _ensureCurrentIndexBounds() {
    if (_quotes.isEmpty) {
      _currentIndex = 0;
      return;
    }
    if (_currentIndex >= _quotes.length) {
      _currentIndex = _quotes.length - 1;
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
