import 'package:material_ui/material_ui.dart';

import '../widgets/left_drawer.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _projectName = '';
  String _description = '';
  String _category = 'Web Development';
  String _technologies = '';
  String _projectLink = '';

  static const _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        scrollable: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nama Proyek: ${_projectName.trim()}'),
            Text('Deskripsi: ${_description.trim()}'),
            Text('Kategori: $_category'),
            Text('Teknologi: ${_technologies.trim()}'),
            Text('Tautan: ${_projectLink.trim()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _formKey.currentState!.reset();
    // Reset juga nilai state agar pengiriman berikutnya tidak memakai data lama.
    setState(() {
      _projectName = '';
      _description = '';
      _category = _categories.first;
      _technologies = '';
      _projectLink = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Isi nama dan deskripsi proyek. Data ditampilkan sebagai ringkasan dan belum disimpan ke database.',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: _decoration('Nama Proyek'),
                        onChanged: (value) => _projectName = value,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nama proyek tidak boleh kosong!'
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: _decoration('Deskripsi Proyek'),
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        onChanged: (value) => _description = value,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Deskripsi proyek tidak boleh kosong!'
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButtonFormField<String>(
                        decoration: _decoration('Kategori Proyek'),
                        // Nilai awal tetap membuat reset selalu kembali ke kategori default.
                        initialValue: _categories.first,
                        isExpanded: true,
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(
                            () => _category = value ?? _categories.first,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: _decoration(
                          'Teknologi yang Digunakan',
                          hint: 'Contoh: Flutter, Django, Figma',
                        ),
                        onChanged: (value) => _technologies = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: _decoration(
                          'Tautan Proyek',
                          hint: 'URL Proyek (opsional)',
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: (value) => _projectLink = value,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                          ),
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
                      ),
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
}
