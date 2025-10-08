import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quote_model.dart';

class QuotesLocalData {
  static const String _assetPath = 'assets/quotes.json';

  List<QuoteModel>? _cache;

  Future<List<QuoteModel>> loadQuotes() async {
    if (_cache != null && _cache!.isNotEmpty) {
      return _cache!;
    }
    final raw = await rootBundle.loadString(_assetPath);
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    _cache = data
        .map((dynamic item) => QuoteModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return _cache!;
  }
}

