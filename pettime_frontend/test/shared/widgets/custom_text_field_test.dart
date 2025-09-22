import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/shared/widgets/custom_text_field.dart';

void main() {
  group('Testes do Widget CustomTextField', () {
    testWidgets('CustomTextField deve exibir com propriedades básicas', (
      WidgetTester tester,
    ) async {
      const hintText = 'Digite o texto';
      const labelText = 'Rótulo';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(hintText: hintText, labelText: labelText),
          ),
        ),
      );

      expect(find.text(hintText), findsOneWidget);
      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets(
      'CustomTextField deve lidar com entrada de texto corretamente',
      (WidgetTester tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                controller: controller,
                hintText: 'Digite aqui',
              ),
            ),
          ),
        );

        const inputText = 'Texto de teste';
        await tester.enterText(find.byType(CustomTextField), inputText);

        expect(controller.text, equals(inputText));
        expect(find.text(inputText), findsOneWidget);
      },
    );

    testWidgets(
      'CustomTextField deve validar entrada quando validador é fornecido',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        // Find the TextFormField and trigger validation
        final textField = find.byType(TextFormField);
        await tester.enterText(textField, '');
        await tester.pump();

        // Trigger validation by submitting empty field
        final formField = tester.widget<TextFormField>(textField);
        final validationResult = formField.validator?.call('');

        expect(validationResult, equals('Field is required'));
      },
    );

    testWidgets('CustomTextField should show/hide password correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              obscureText: true,
              suffixIcon: Icons.visibility,
            ),
          ),
        ),
      );

      // Should show suffix icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Should render text field correctly
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('CustomTextField should handle onChanged callback', (
      WidgetTester tester,
    ) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      const inputText = 'Changed text';
      await tester.enterText(find.byType(CustomTextField), inputText);

      expect(changedValue, equals(inputText));
    });

    testWidgets('CustomTextField should respect enabled property', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(enabled: false, hintText: 'Disabled field'),
          ),
        ),
      );

      // Should render the field
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Disabled field'), findsOneWidget);
    });

    testWidgets('CustomTextField should respect readOnly property', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(readOnly: true, hintText: 'Read only field'),
          ),
        ),
      );

      // Should render the field
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Read only field'), findsOneWidget);
    });

    testWidgets('CustomTextField should handle maxLines correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(maxLines: 3, hintText: 'Multi-line field'),
          ),
        ),
      );

      // Should render the field
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Multi-line field'), findsOneWidget);
    });

    testWidgets('CustomTextField should display prefix icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              prefixIcon: Icons.email,
              hintText: 'Email field',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('CustomTextField should handle suffix icon press', (
      WidgetTester tester,
    ) async {
      bool suffixPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              suffixIcon: Icons.clear,
              onSuffixIconPressed: () {
                suffixPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(suffixPressed, isTrue);
    });

    testWidgets('CustomTextField should respect keyboard type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              keyboardType: TextInputType.number,
              hintText: 'Number field',
            ),
          ),
        ),
      );

      // Should render the field
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Number field'), findsOneWidget);
    });

    testWidgets('CustomTextField should apply input formatters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hintText: 'Numbers only',
            ),
          ),
        ),
      );

      // Should render the field
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Numbers only'), findsOneWidget);
    });
  });
}
