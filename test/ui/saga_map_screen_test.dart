import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/app/saga_app.dart';
import 'package:learn_english_flutter/saga_map/saga_map_game.dart';

void main() {
  testWidgets('launches, opens HUD panels, toggles debug, and scrolls', (
    tester,
  ) async {
    await tester.pumpWidget(const SagaApp());
    await _pumpFrames(tester, 120);

    final gameFinder = find.byType(GameWidget<SagaMapGame>);
    expect(gameFinder, findsOneWidget);
    expect(find.text('CHAPTER 1'), findsOneWidget);

    await tester.tap(find.byTooltip('Books'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Story books'), findsOneWidget);
    Navigator.of(tester.element(find.text('Story books'))).pop();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Show debug overlay'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Progress:'), findsOneWidget);

    final game = tester.widget<GameWidget<SagaMapGame>>(gameFinder).game!;
    game.applyDragDelta(320);
    game.update(1);
    game.update(1);
    await tester.pump();
    expect(game.state.progress, greaterThan(0));
    expect(game.state.currentLevel, greaterThan(0));
  });

  testWidgets('tapping the current node opens its interaction panel', (
    tester,
  ) async {
    await tester.pumpWidget(const SagaApp());
    await _pumpFrames(tester, 120);

    final gameFinder = find.byType(GameWidget<SagaMapGame>);
    final map = tester.getRect(gameFinder);
    final game = tester.widget<GameWidget<SagaMapGame>>(gameFinder).game!;
    final recorder = ui.PictureRecorder();
    game.render(ui.Canvas(recorder));
    recorder.endRecording();
    game.onTapDown(
      1,
      TapDownInfo.fromDetails(
        game,
        TapDownDetails(
          globalPosition: Offset(map.center.dx, map.top + map.height * 0.48),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Saga step 1'), findsOneWidget);
    expect(find.textContaining('current lesson'), findsOneWidget);
  });

  testWidgets('HUD reward count changes only after collection arrival', (
    tester,
  ) async {
    await tester.pumpWidget(const SagaApp());
    await _pumpFrames(tester, 120);

    final gameFinder = find.byType(GameWidget<SagaMapGame>);
    final game = tester.widget<GameWidget<SagaMapGame>>(gameFinder).game!;
    expect(find.text('39'), findsOneWidget);

    game.moveToLevel(1);
    game.update(1 / 15);
    await tester.pump();
    expect(find.text('39'), findsOneWidget);

    game.update(1.2);
    await tester.pump();
    await tester.pump();
    expect(find.text('42'), findsOneWidget);
  });
}

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}
