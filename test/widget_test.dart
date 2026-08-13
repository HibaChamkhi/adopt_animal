import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';

void main() {
  testWidgets('EmptyState shows its title and subtitle', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: EmptyState(
          icon: Icons.pets,
          title: "Nothing here",
          subtitle: "Come back later",
        ),
      ),
    ));
    expect(find.text("Nothing here"), findsOneWidget);
    expect(find.text("Come back later"), findsOneWidget);
  });

  testWidgets('PrimaryButton renders its label and fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PrimaryButton(label: "Go", onTap: () => tapped = true),
      ),
    ));
    expect(find.text("Go"), findsOneWidget);
    await tester.tap(find.text("Go"));
    expect(tapped, isTrue);
  });
}
