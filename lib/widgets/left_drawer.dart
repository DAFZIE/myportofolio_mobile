import 'package:material_ui/material_ui.dart';

import '../screens/menu.dart';
import '../screens/education_form.dart';
import '../screens/project_form.dart';
import '../screens/project_list_screen.dart';
import '../services/auth_state.dart';
import 'auth_guard.dart';

import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _replacePage(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop(); // Tutup drawer sebelum mengganti halaman aktif.
    navigator.pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colors.primary),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => _replacePage(context, MyHomePage()),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Lihat Proyek'),
            onTap: () => _replacePage(context, const ProjectListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              if (!await ensureLoggedIn(context) || !context.mounted) return;
              navigator.push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProjectFormPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Tambah Pendidikan'),
            onTap: () => _replacePage(context, const EducationFormPage()),
          ),
          ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
            title: Text(isLoggedIn ? 'Logout' : 'Login'),
            onTap: () async {
              Navigator.pop(context);
              if (isLoggedIn) {
                await logoutWithFeedback(context);
              } else {
                await ensureLoggedIn(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
