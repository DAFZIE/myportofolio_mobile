import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../screens/login_screen.dart';
import '../services/auth_state.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
  return result == true;
}

Future<void> logoutWithFeedback(BuildContext context) async {
  var message = 'Berhasil logout.';
  try {
    await context.read<AuthState>().logout();
  } catch (_) {
    message = 'Logout lokal berhasil. Token server belum dapat dicabut; periksa koneksi Anda.';
  }
  if (!context.mounted) return;
  Navigator.of(context).popUntil((route) => route.isFirst);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
