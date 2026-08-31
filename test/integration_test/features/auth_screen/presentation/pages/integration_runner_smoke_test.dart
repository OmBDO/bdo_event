import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../../../shared/harness/integration_app_harness.dart';
import '../../../../shared/harness/test_duration.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots the integration runner with a minimal widget',
      (tester) async {
    final durations = TestDurationRecorder();
    await durations.measure('integration-runner-smoke', () async {
      const app = IntegrationAppHarness(
        home: Scaffold(body: Text('Integration runner ready')),
      );
      await tester.pumpWidget(app.build());
    });

    expect(find.text('Integration runner ready'), findsOneWidget);
    expect(durations.records.single.name, 'integration-runner-smoke');
  });
}
