### Tutorial 10

Implemented public project list/detail screens, generated JSON models, token login
and logout, guarded project creation, API error handling, and GitHub Actions CI/CD.
The existing Education form remains the local form from Assignment 8; its backend
integration belongs to Assignment 9.

**Backend setup:** apply [the Django patch](backend_changes/README.md), install
requirements, run migrations, and start Django on port 8000. Use a Django superuser
to create projects. The backend from the supplied ZIP needed the included schema
migration before it could accept the tutorial's payload.

**Flutter setup and run:**

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

For an Android emulator, `flutter run` defaults to `http://10.0.2.2:8000`.
For a physical Android device connected through USB, run
`adb reverse tcp:8000 tcp:8000`, then
`flutter run --dart-define=API_BASE_URL=http://localhost:8000`.
For a deployed backend, pass its HTTPS URL with `--dart-define=API_BASE_URL=...`.
Use the Dart executable bundled with Flutter 3.50.0 (Dart 3.14); an older standalone
Dart installation will fail the SDK constraint.

**How the code fits together:**

- `models/project.dart` maps Dart camelCase to the API's snake_case keys. UUIDs are
  read from the server and excluded from POST bodies; the image URL is optional.
- `services/api_client.dart` owns HTTP requests, token headers, timeouts and safe
  status messages. `services/auth_state.dart` holds the token in memory only.
- `main.dart` supplies both services through Provider. `widgets/auth_guard.dart`
  opens login before protected actions. Cancelling login cancels the action.
- The project list caches its Future and supports loading, errors, retry, empty
  results and pull-to-refresh. Tapping a project opens its detail screen.
- The form validates fields and URLs and only shows success after an API save.
  A 401 clears the session and asks for login again while retaining the form.
  Press Save after re-authentication to retry. A 403 explains the permission issue.
- Logout clears local state even when the server cannot be reached; the message
  tells the user when server-side revocation could not be confirmed.

**CI/CD:** `.github/workflows/main.yaml` uses the tutorial's
[Very Good Workflows reusable workflow](https://github.com/VeryGoodOpenSource/very_good_workflows/blob/v2/.github/workflows/flutter_package.yml)
for generation, formatting, analysis and tests. The dependent `build_apk` job
builds and uploads `app-release-apk`. Optionally set the GitHub Actions repository
variable `API_BASE_URL` to your deployed backend; if unset, CI uses the emulator
default instead of an empty URL. The workflow is prepared locally; it has not
been pushed or run on GitHub.

Local verification: `flutter analyze`, 12 Flutter tests, `flutter build web`,
36 Django tests, and a real HTTP smoke check using the Dart API client passed.
Local APK compilation requires an Android SDK, which was unavailable here.
Android cleartext HTTP is enabled for tutorial development; disable it when
shipping an HTTPS-only production app. Release signing remains the starter
project's debug signing configuration, suitable for this tutorial's APK artifact.

After reviewing and pushing the work, check that both GitHub Actions jobs pass
and submit the commit link in SCELE yourself.

### Tugas 7

Saya tidak kelar mengerjakan tutorial 8, jadi saya tidak mengumpul tugas 7.

### Tugas 8

1. Navigator.push() menambahkan halaman baru ke atas tumpukan navigasi. Navigator.pushReplacement() mengganti halaman teratas dengan halaman baru. Navigator.pop() menutup halaman teratas dan kembali ke halaman di bawahnya. Opsi Home memanggil pop() untuk menutup drawer, lalu pushReplacement() untuk mengganti halaman aktif dengan MyHomePage.

2. Scaffold untuk kerangka halaman (tempat untuk AppBar, Drawer, isi halaman). AppBar untuk judul, Drawer untuk navigasi yang konsisten LeftDrawer pada halaman utama dan form. Warna diambil dari tema bersama. Contohnya, AppBar halaman utama dan form Pendidikan sama-sama menggunakan Theme.of(context).colorScheme.primary (ungu tua #4A155F). 

3. Form pakai Column agar input tersusun vertikal dan mudah diisi secara berurutan. Padding memberi jarak antara konten dan tepi layar, sedangkan SizedBox memberi jarak antarinput agar tampilannya tidak terlalu rapat. SingleChildScrollView membuat agar formulir digulir ketika tinggi layar terbatas atau keyboard muncul, sehingga input dan tombol Simpan tetap mudah diclick. SafeArea menghindarkan konten dari area sistem perangkat, sementara ConstrainedBox membatasi lebar formulir agar tidak terlalu melebar pada layar desktop.

4. GlobalKey<FormState> memberikan akses ke state formulir. Setiap input memiliki validator yang mengembalikan pesan kesalahan jika nilainya tidak valid, atau null jika valid.

Saat Simpan ditekan, _formKey.currentState!.validate() menjalankan seluruh validator. Jika hasilnya false, pesan kesalahan ditampilkan pada kolom terkait. Dialog ringkasan hanya dibuka jika seluruh input valid.

Contohnya, nama pendidikan "   " ditolak karena setelah spasi dibersihkan dengan trim(), nilainya kosong. Tanggal selesai yang mendahului tanggal mulai juga ditolak.

Jenis input atau keyboard hanya membantu pengguna memasukkan data. Keduanya tidak memastikan aturan terpenuhi: pengguna masih dapat memasukkan spasi, menempelkan teks terlalu panjang, atau memilih urutan tanggal yang salah. Karena itu, validasi tetap diperlukan.

AI Disclosure: Saya menggunakan GPT-6 Astra dengan effort Medium. Saya menggunakan AI ini untuk mengerjakan 90% dari tugas ini. Saya tidak 100% menyalin jawaban, tapi saya baca dulu kegunaan dan penjelasan codenya (Saat prompt, saya eksplisitly minta untuk penjelasan tiap section kode nya). Jika saya rasa ada janggal, atau tidak koheren, saya langsung ubah atau minta untuk jelaskan kenapa AI-nya melakukan hal tersebut.
