import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';

Finder field(String key) => find.byKey(ValueKey(key));

Future<void> save(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Simpan'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

Future<void> chooseDate(WidgetTester tester, String key, DateTime date) async {
  await tester.ensureVisible(field(key));
  await tester.pumpAndSettle();
  await tester.tap(field(key));
  await tester.pumpAndSettle();
  // Pilih tanggal tertentu lewat callback kalender, lalu konfirmasi kedua dialog.
  tester
      .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
      .onDateChanged(date);
  await tester.pump();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  expect(find.byType(TimePickerDialog), findsOneWidget);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> fillRequired(WidgetTester tester) async {
  await tester.enterText(field('title'), '<b>Universitas Indonesia</b>');
  await tester.enterText(field('description'), 'Belajar Ilmu Komputer');
  await tester.ensureVisible(field('level'));
  await tester.pumpAndSettle();
  await tester.tap(field('level'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('S1').last);
  await tester.pumpAndSettle();
  await chooseDate(tester, 'started_at', DateTime(2025, 8, 1));
}

void main() {
  testWidgets('Long summary scrolls and can close on a narrow screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    await fillRequired(tester);
    await tester.enterText(
      field('description'),
      'Riwayat pendidikan panjang. ' * 100,
    );
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpAndSettle();
    await save(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.ensureVisible(find.text('Tanggal Selesai: Masih berlangsung'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tanggal Selesai: Masih berlangsung').hitTestable(),
      findsOneWidget,
    );
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      tester.widget<TextFormField>(field('description')).controller!.text,
      'Riwayat pendidikan panjang. ' * 99 + 'Riwayat pendidikan panjang.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Education enforces required fields, HTML-only rejection and model length',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
      await save(tester);
      expect(find.text('Nama pendidikan wajib diisi.'), findsOneWidget);
      expect(find.text('Deskripsi pendidikan wajib diisi.'), findsOneWidget);
      expect(find.text('Pilih jenjang pendidikan.'), findsOneWidget);
      expect(find.text('Tanggal mulai wajib diisi.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(field('title'), '   ');
      await tester.enterText(field('description'), '<p> </p>');
      await save(tester);
      expect(find.text('Nama pendidikan wajib diisi.'), findsOneWidget);
      expect(
        find.text('Deskripsi pendidikan tidak boleh hanya berisi tag HTML.'),
        findsOneWidget,
      );
      await tester.enterText(field('title'), 'a' * 256);
      await save(tester);
      expect(
        find.text('Nama pendidikan maksimal 255 karakter.'),
        findsOneWidget,
      );
      await tester.enterText(field('title'), 'a' * 255);
      await save(tester);
      expect(find.text('Nama pendidikan maksimal 255 karakter.'), findsNothing);
    },
  );

  testWidgets('Education validates date order and supports ongoing education', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    await fillRequired(tester);
    await chooseDate(tester, 'ended_at', DateTime(2024, 8, 1));
    await save(tester);
    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    await chooseDate(tester, 'ended_at', DateTime(2029, 8, 1));
    await save(tester);
    expect(find.text('Ringkasan Pendidikan'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(field('title')).controller!.text,
      'Universitas Indonesia',
    );
    expect(find.text('Nama Pendidikan: Universitas Indonesia'), findsOneWidget);
    expect(
      find.text('Deskripsi Pendidikan: Belajar Ilmu Komputer'),
      findsOneWidget,
    );
    expect(find.text('Jenjang Pendidikan: S1'), findsOneWidget);
    final startText = tester
        .widget<TextFormField>(field('started_at'))
        .controller!
        .text;
    final endText = tester
        .widget<TextFormField>(field('ended_at'))
        .controller!
        .text;
    expect(find.text('Tanggal Mulai: $startText'), findsOneWidget);
    expect(find.text('Tanggal Selesai: $endText'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      tester.widget<TextFormField>(field('title')).controller!.text,
      'Universitas Indonesia',
    );
    await tester.enterText(field('title'), 'Pendidikan diperbarui');
    await tester.ensureVisible(find.byTooltip('Hapus tanggal selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus tanggal selesai'));
    await tester.pumpAndSettle();
    await save(tester);
    expect(find.text('Ringkasan Pendidikan'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(field('ended_at')).controller!.text,
      isEmpty,
    );
    expect(find.text('Nama Pendidikan: Pendidikan diperbarui'), findsOneWidget);
    expect(find.text('Tanggal Selesai: Masih berlangsung'), findsOneWidget);
  });

  testWidgets('Save remains reachable on narrow screen with keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await tester.enterText(field('description'), 'Deskripsi');
    await save(tester);
    expect(find.text('Nama pendidikan wajib diisi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
