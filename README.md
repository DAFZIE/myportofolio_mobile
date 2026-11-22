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