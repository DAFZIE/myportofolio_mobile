import 'package:html/parser.dart' show parseFragment;
import 'package:material_ui/material_ui.dart';

import '../widgets/left_drawer.dart';

/// Mengikuti field EducationForm pada main/forms.py portofolio Django.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _startText = TextEditingController();
  final _endText = TextEditingController();
  DateTime? _startedAt;
  DateTime? _endedAt;

  static const _levels = ['SD', 'SMP', 'SMA', 'S1', 'S2', 'S3'];

  // Ini normalisasi input teks, bukan pengganti validasi keamanan di server.
  String _cleanText(String value) => (parseFragment(value).text ?? '').trim();

  String? _validateText(String? value, String label, {int? maxLength}) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return '$label wajib diisi.';
    // ModelForm memeriksa panjang sebelum clean_title menghapus tag HTML.
    if (maxLength != null && raw.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    if (_cleanText(raw).isEmpty) {
      return '$label tidak boleh hanya berisi tag HTML.';
    }
    return null;
  }

  String _formatDateTime(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year.toString().padLeft(4, '0')} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial =
        (isStart ? _startedAt : _endedAt) ?? _startedAt ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        _startedAt = selected;
        _startText.text = _formatDateTime(selected);
      } else {
        _endedAt = selected;
        _endText.text = _formatDateTime(selected);
      }
    });
  }

  Widget _dateField({required bool isStart}) {
    return TextFormField(
      key: ValueKey(isStart ? 'started_at' : 'ended_at'),
      controller: isStart ? _startText : _endText,
      readOnly: true,
      onTap: () => _pickDateTime(isStart: isStart),
      decoration: InputDecoration(
        labelText: isStart
            ? 'Tanggal Mulai Pendidikan'
            : 'Tanggal Selesai Pendidikan',
        helperText: isStart
            ? 'Pilih tanggal dan waktu mulai.'
            : 'Opsional; kosong berarti masih berlangsung.',
        helperMaxLines: 2,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: !isStart && _endedAt != null
            ? IconButton(
                tooltip: 'Hapus tanggal selesai',
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() {
                  _endedAt = null;
                  _endText.clear();
                }),
              )
            : null,
      ),
      validator: (_) {
        if (isStart && _startedAt == null) return 'Tanggal mulai wajib diisi.';
        if (!isStart &&
            _endedAt != null &&
            _startedAt != null &&
            _endedAt!.isBefore(_startedAt!)) {
          return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
        }
        return null;
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _title.text = _cleanText(_title.text);
    _description.text = _cleanText(_description.text);
    // Tahap ini baru formulir: belum ada dialog ringkasan atau penyimpanan API.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Isian pendidikan valid. Data belum disimpan.'),
        ),
      );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _startText.dispose();
    _endText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: AppBar(
        title: const Text('Tambah Pendidikan'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Lengkapi riwayat pendidikan. Tanggal selesai boleh dikosongkan jika pendidikan masih berlangsung.',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const ValueKey('title'),
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pendidikan',
                        hintText: 'Nama Sekolah/Universitasmu',
                        helperText: 'Maksimal 255 karakter.',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _validateText(
                        value,
                        'Nama pendidikan',
                        maxLength: 255,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('description'),
                      controller: _description,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Pendidikan',
                        hintText: 'Deskripsi Jenjang Pendidikanmu',
                      ),
                      minLines: 3,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      validator: (value) =>
                          _validateText(value, 'Deskripsi pendidikan'),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('level'),
                      decoration: const InputDecoration(
                        labelText: 'Jenjang Pendidikan',
                      ),
                      isExpanded: true,
                      items: _levels
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ),
                          )
                          .toList(),
                      onChanged: (_) {},
                      validator: (value) => _levels.contains(value)
                          ? null
                          : 'Pilih jenjang pendidikan.',
                    ),
                    const SizedBox(height: 20),
                    _dateField(isStart: true),
                    const SizedBox(height: 20),
                    _dateField(isStart: false),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan'),
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
