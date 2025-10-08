import 'dart:convert';

class QuoteModel {
  QuoteModel({
    required this.text,
    required this.author,
  });

  final String text;
  final String author;

  String get storageId =>
      '${Uri.encodeComponent(text)}|${Uri.encodeComponent(author)}';

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      text: json['text'] as String? ?? '',
      author: json['author'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'author': author,
      };

  factory QuoteModel.fromStorageId(String id) {
    final parts = id.split('|');
    if (parts.length != 2) {
      return QuoteModel(text: id, author: 'Unknown');
    }
    return QuoteModel(
      text: Uri.decodeComponent(parts[0]),
      author: Uri.decodeComponent(parts[1]),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteModel &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author;

  @override
  int get hashCode => Object.hash(text, author);

  @override
  String toString() => jsonEncode(toJson());
}

