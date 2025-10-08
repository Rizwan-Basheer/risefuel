import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/utils/date_helper.dart';
import 'data/local/quotes_local_data.dart';
import 'data/remote/quotes_api.dart';
import 'viewmodel/quotes_viewmodel.dart';
import 'ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final viewModel = QuotesViewModel(
    localData: QuotesLocalData(),
    remoteData: QuotesApi(),
    sharedPreferences: sharedPreferences,
    dateHelper: const DateHelper(),
  );
  await viewModel.initialize();
  runApp(DailyQuotesApp(viewModel: viewModel));
}

class DailyQuotesApp extends StatelessWidget {
  const DailyQuotesApp({super.key, required this.viewModel});

  final QuotesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuotesViewModel>.value(
      value: viewModel,
      child: Consumer<QuotesViewModel>(
        builder: (_, vm, __) {
          return MaterialApp(
            title: 'Daily Quotes',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: vm.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
    );

    return base.copyWith(
      textTheme: GoogleFonts.latoTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
    );

    return base.copyWith(
      textTheme: GoogleFonts.latoTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
    );
  }
}
