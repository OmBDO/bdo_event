import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'integration_app_harness.dart';

void main() {
  testWidgets('injects providers before rendering the home widget', (
    tester,
  ) async {
    final cubit = _ProbeCubit();
    await tester.pumpWidget(
      IntegrationAppHarness(
        providers: [BlocProvider.value(value: cubit)],
        home: Builder(
          builder: (context) => Text(context.watch<_ProbeCubit>().state),
        ),
      ).build(),
    );

    expect(find.text('ready'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('renders a home widget without providers', (tester) async {
    await tester.pumpWidget(
      const IntegrationAppHarness(home: Text('standalone home')).build(),
    );

    expect(find.text('standalone home'), findsOneWidget);
  });
}

class _ProbeCubit extends Cubit<String> {
  _ProbeCubit() : super('ready');
}
