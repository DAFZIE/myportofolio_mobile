import 'package:material_ui/material_ui.dart';

import '../screens/menu.dart';
import '../screens/education_form.dart';
import '../screens/project_form.dart';
import '../screens/project_list_screen.dart';
import '../services/auth_state.dart';
import 'auth_guard.dart';

import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Setiap aksi memiliki warna berbeda dari palet portofolio.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () async {
          // Menampilkan SnackBar dengan pesan interaktif.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("Kamu telah menekan tombol ${item.name}!"),
              ),
            );
          if (item.name == 'Tambah Proyek') {
            if (!await ensureLoggedIn(context) || !context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ProjectFormPage()),
            );
          } else if (item.name == 'Lihat Proyek') {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ProjectListScreen(),
              ),
            );
          } else if (item.name == 'Logout') {
            if (context.read<AuthState>().isLoggedIn) {
              await logoutWithFeedback(context);
            } else {
              await ensureLoggedIn(context);
            }
          } else if (item.name == 'Tambah Pendidikan') {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const EducationFormPage(),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: item.foregroundColor, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name == 'Logout' &&
                          !context.watch<AuthState>().isLoggedIn
                      ? 'Login'
                      : item.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: item.foregroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
