// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:risefuel/core/utils/date_helper.dart';
import 'package:risefuel/data/local/quotes_local_data.dart';
import 'package:risefuel/data/models/quote_model.dart';
import 'package:risefuel/main.dart';
import 'package:risefuel/viewmodel/quotes_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DailyQuotesApp displays the daily quote', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final viewModel = QuotesViewModel(
      localData: _FakeQuotesLocalData(),
      sharedPreferences: prefs,
      dateHelper: const DateHelper(),
    );
    await viewModel.initialize();

    await tester.pumpWidget(DailyQuotesApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    expect(find.text('Quote of the Day'), findsOneWidget);
    expect(find.textContaining('Test quote for UI'), findsOneWidget);
    expect(find.textContaining('— Test Author'), findsOneWidget);
  });
}

class _FakeQuotesLocalData extends QuotesLocalData {
  @override
  Future<List<QuoteModel>> loadQuotes() async {
    return <QuoteModel>[
      QuoteModel(
        text: 'Test quote for UI rendering in widget test.',
        author: 'Test Author',
      ),
    ];
  }
}
