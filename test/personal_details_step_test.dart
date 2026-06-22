import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/widgets/onboarding/personal_details_step.dart';

void main() {
  // Regression: gender chips overflowed the row on narrow screens.
  // Wrap must lay them out with no RenderFlex overflow at iPhone SE width.
  testWidgets('gender chips wrap without overflow at 320px width', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PersonalDetailsStep(
          nameCtrl: TextEditingController(),
          age: 30,
          gender: Gender.male,
          height: 175,
          weight: 70,
          heightUnit: HeightUnit.cm,
          weightUnit: WeightUnit.kg,
          onChanged: ({age, gender, height, weight, heightUnit, weightUnit}) {},
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
    // All four gender labels are present (Wrap kept them all on screen).
    for (final g in Gender.values) {
      expect(find.text(g.label), findsOneWidget);
    }
  });
}
