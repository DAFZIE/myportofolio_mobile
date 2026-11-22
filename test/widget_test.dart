import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';

Future<void> openForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.ensureVisible(find.text('Tambah Proyek'));
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  // Tunggu SnackBar kartu selesai agar tombol di bawah layar tidak tertutup.
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Future<void> openDrawer(WidgetTester tester) async {
  tester.state<ScaffoldState>(find.byType(Scaffold).last).openDrawer();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Education card pushes form; Back and drawer Home return to menu',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      Future<void> openEducation() async {
        await tester.ensureVisible(find.text('Tambah Pendidikan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tambah Pendidikan'));
        await tester.pumpAndSettle();
      }

      await openEducation();
      expect(find.byType(EducationFormPage), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(EducationFormPage))).canPop(),
        isTrue,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      await openEducation();
      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(EducationFormPage), findsNothing);
    },
  );

  testWidgets(
    'Shared drawer opens Education, Home and Add Project on a phone',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Tambah Pendidikan'));
      await tester.pumpAndSettle();
      expect(find.byType(EducationFormPage), findsOneWidget);
      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Tambah Pendidikan'));
      await tester.pumpAndSettle();
      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);
      await openDrawer(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Tambah Pendidikan'));
      await tester.pumpAndSettle();
      expect(find.byType(EducationFormPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Card pushes form and system Back returns to Home', (
    tester,
  ) async {
    await openForm(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Drawer replaces current page for Add Project and Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await openDrawer(tester);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
      isFalse,
    );
    await openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets(
    'Required validation, summary and reset including dropdown state',
    (tester) async {
      await openForm(tester);
      await save(tester);
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '   ');
      await tester.enterText(fields.at(1), '   ');
      await save(tester);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(fields.at(0), 'MyPortfolio');
      await tester.enterText(fields.at(1), 'Portofolio Flutter');
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Web Development').hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(2), 'Flutter, Dart');
      await tester.enterText(fields.at(3), 'https://example.com');
      await save(tester);
      for (final value in [
        'Nama Proyek: MyPortfolio',
        'Deskripsi: Portofolio Flutter',
        'Kategori: Mobile Development',
        'Teknologi: Flutter, Dart',
        'Tautan: https://example.com',
      ]) {
        expect(find.text(value), findsOneWidget);
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      for (final field in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(field.controller.text, isEmpty);
      }
      expect(
        tester
            .state<FormFieldState<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .value,
        'Web Development',
      );
      await tester.enterText(fields.at(0), 'Proyek kedua');
      await tester.enterText(fields.at(1), 'Deskripsi baru');
      await save(tester);
      expect(find.text('Nama Proyek: Proyek kedua'), findsOneWidget);
      expect(find.text('Kategori: Web Development'), findsOneWidget);
      expect(find.text('Teknologi: '), findsOneWidget);
      expect(find.text('Tautan: '), findsOneWidget);
      expect(find.text('Teknologi: Flutter, Dart'), findsNothing);
    },
  );

  testWidgets('Form remains scrollable on narrow screen with keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await openForm(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Proyek');
    await tester.enterText(find.byType(TextFormField).at(1), 'Deskripsi');
    await save(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
