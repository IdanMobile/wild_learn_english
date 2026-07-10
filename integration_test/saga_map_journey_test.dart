import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn_english_flutter/app/saga_app.dart';
import 'package:learn_english_flutter/saga_map/saga_map_game.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('saga map Android journey', (tester) async {
    await tester.pumpWidget(const SagaApp());
    await _pumpFor(tester, const Duration(seconds: 2));

    expect(find.byType(GameWidget<SagaMapGame>), findsOneWidget);
    expect(find.text('CHAPTER 1'), findsOneWidget);

    for (var step = 0; step < 5; step++) {
      await tester.tap(find.byTooltip('Advance 1 level'));
      await _pumpFor(tester, const Duration(milliseconds: 900));
    }
    expect(find.text('LESSON 6  •  SAGA STEP 5'), findsOneWidget);

    await tester.tap(find.byTooltip('Books'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Story books'), findsOneWidget);
    Navigator.of(tester.element(find.text('Story books'))).pop();
    await tester.pump(const Duration(milliseconds: 400));

    final game = tester
        .widget<GameWidget<SagaMapGame>>(find.byType(GameWidget<SagaMapGame>))
        .game!;
    final levelBeforeDrag = game.state.currentLevel;
    await tester.drag(
      find.byType(GameWidget<SagaMapGame>),
      const Offset(0, 360),
    );
    await _pumpFor(tester, const Duration(seconds: 2));
    expect(game.state.currentLevel, greaterThan(levelBeforeDrag));
  });
}

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  const frame = Duration(milliseconds: 16);
  final frames = duration.inMilliseconds ~/ frame.inMilliseconds;
  for (var index = 0; index < frames; index++) {
    await tester.pump(frame);
  }
}
