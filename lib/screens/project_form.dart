import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../services/api_client.dart';
import '../services/auth_state.dart';
import '../widgets/auth_guard.dart';
import '../widgets/left_drawer.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});
  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '',
      _description = '',
      _techStack = '',
      _url = '',
      _imageUrl = '';
  bool _saving = false;

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Kolom ini wajib diisi.' : null;

  String? _validateUrl(String? value, {bool optional = false}) {
    if (optional && (value == null || value.trim().isEmpty)) return null;
    final uri = Uri.tryParse(value?.trim() ?? '');
    return uri != null &&
            ['http', 'https'].contains(uri.scheme) &&
            uri.host.contains('.')
        ? null
        : 'Masukkan URL http:// atau https:// yang valid.';
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final token = context.read<AuthState>().token;
      if (token == null) return;
      final project = Project(
        title: _title.trim(),
        description: _description.trim(),
        techStack: _techStack.trim(),
        projectUrl: _url.trim(),
        projectImageUrl: _imageUrl.trim(),
      );
      await context.read<ApiClient>().createProject(project, token: token);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: Text('${project.title} telah disimpan ke database.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _title = _description = _techStack = _url = _imageUrl = '';
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        try {
          await context.read<AuthState>().logout();
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesi berakhir. Login kembali, lalu tekan Save untuk mencoba lagi.',
            ),
          ),
        );
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${error.message} (${error.statusCode})')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak dapat menyimpan proyek. Periksa koneksi dan coba lagi.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Add Project Form'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    drawer: const LeftDrawer(),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Isi data proyek untuk disimpan ke portofolio Anda.',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 255,
                    enabled: !_saving,
                    onChanged: (v) => _title = v,
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    enabled: !_saving,
                    onChanged: (v) => _description = v,
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Tech Stack',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 255,
                    enabled: !_saving,
                    onChanged: (v) => _techStack = v,
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Project URL',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 200,
                    keyboardType: TextInputType.url,
                    enabled: !_saving,
                    onChanged: (v) => _url = v,
                    validator: _validateUrl,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Project Image URL (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 200,
                    keyboardType: TextInputType.url,
                    enabled: !_saving,
                    onChanged: (v) => _imageUrl = v,
                    validator: (v) => _validateUrl(v, optional: true),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Menyimpan...' : 'Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
