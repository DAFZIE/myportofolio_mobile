import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/portfolio_colors.dart';
import 'package:provider/provider.dart';

import 'services/api_client.dart';
import 'services/auth_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.apiClient, this.initialToken});

  final ApiClient? apiClient;
  final String? initialToken;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => apiClient ?? ApiClient(),
          dispose: (_, client) {
            if (apiClient == null) client.close();
          },
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthState(context.read<ApiClient>(), initialToken: initialToken),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
