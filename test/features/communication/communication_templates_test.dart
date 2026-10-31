import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/communication/presentation/communication_hub_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';

void main() {
  group('Message Templates (Template Pesan Teman Tuli) Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.clearMessages();
    });

    testWidgets('Renders message template chips above bottom input bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CommunicationHubScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Template'), findsOneWidget);
      expect(find.text('Tanya arah jalan'), findsOneWidget);
      expect(find.text('Saya Teman Tuli'), findsOneWidget);
      expect(find.text('Di mana toilet?'), findsOneWidget);
    });

    testWidgets('Tapping template chip populates text into input field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CommunicationHubScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tanya arah jalan'));
      await tester.pumpAndSettle();

      expect(find.text('Permisi, boleh tanya arah jalan?'), findsOneWidget);
    });

    testWidgets('Tapping Template button opens categorized everyday templates sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CommunicationHubScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Template'));
      await tester.pumpAndSettle();

      expect(find.text('Template Pesan Sehari-hari'), findsOneWidget);
      expect(find.text('Arah Jalan & Transportasi'), findsOneWidget);

      // Tap one of the visible templates inside the sheet
      await tester.tap(find.text('Di mana letak toilet terdekat?'));
      await tester.pumpAndSettle();

      // Sheet closes and input contains the selected template text
      expect(find.text('Di mana letak toilet terdekat?'), findsOneWidget);
    });
  });
}
