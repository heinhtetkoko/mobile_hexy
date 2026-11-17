import 'package:mobile_hexy/core/services/asset_paths.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/app_translations.dart';
import 'package:mobile_hexy/core/theme/app_theme.dart';
import 'package:mobile_hexy/data/models/app_version_policy.dart';
import 'package:mobile_hexy/presentation/view/app_update_page.dart';

void main() {
  tearDown(() => Get.reset());
  for (final dark in [false, true]) {
    for (final narrow in [false, true]) {
      testWidgets('update layout dark=$dark narrow=$narrow', (tester) async {
        final preview = Platform.environment['HEXCY_PREVIEW_DIRECTORY'];
        if (preview != null) {
          await tester.runAsync(() async {
            final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
            if (await font.exists()) {
              final loader = FontLoader('PreviewFont')
                ..addFont(
                  Future.value(ByteData.sublistView(await font.readAsBytes())),
                );
              await loader.load();
              final icons = FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
              await icons.load();
            }
          });
        }
        tester.view.physicalSize = Size(narrow ? 320 : 390, narrow ? 640 : 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              translations: AppTranslations(),
              locale: narrow
                  ? const Locale('my', 'MM')
                  : const Locale('en', 'US'),
              theme: AppTheme.light.copyWith(
                textTheme: preview == null
                    ? null
                    : ThemeData.light().textTheme.apply(
                        fontFamily: 'PreviewFont',
                      ),
              ),
              darkTheme: AppTheme.dark.copyWith(
                textTheme: preview == null
                    ? null
                    : ThemeData.dark().textTheme.apply(
                        fontFamily: 'PreviewFont',
                      ),
              ),
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(narrow ? 1.6 : 1)),
                child: child!,
              ),
              home: AppUpdatePage(
                update: AvailableAppUpdate(
                  policy: const AppVersionPolicy(
                    version: '1.0.1',
                    forceUpdate: true,
                  ),
                  installedVersion: '1.0.0',
                  storeUrl: Uri.parse('https://example.com'),
                ),
                openStore: (_) async => true,
              ),
            ),
          ),
        );
        if (preview != null) {
          await tester.runAsync(() async {
            await precacheImage(
              const AssetImage(AssetPaths.appLogo),
              tester.element(find.byType(AppUpdatePage)),
            );
          });
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byKey(const Key('app-update-now')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (preview != null && !narrow) {
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            // Warm up glyph and image rasterization before saving the preview.
            final warmup = await render.toImage(pixelRatio: 2);
            await warmup.toByteData(format: ui.ImageByteFormat.png);
            warmup.dispose();
            final image = await render.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory(preview).create(recursive: true);
            await File(
              '$preview/update-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      });
    }
  }
}
