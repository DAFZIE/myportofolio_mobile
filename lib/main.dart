import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/portfolio_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: PortfolioColors.accent,
          primary: PortfolioColors.accentDark,
          onPrimary: Colors.white,
          secondary: PortfolioColors.accent,
          onSecondary: Colors.white,
          surface: PortfolioColors.paper,
          onSurface: PortfolioColors.ink,
          outline: PortfolioColors.line,
        ),
        scaffoldBackgroundColor: PortfolioColors.paper,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: PortfolioColors.ink,
          contentTextStyle: TextStyle(color: PortfolioColors.paper),
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
