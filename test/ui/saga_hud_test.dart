import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/domain/saga_map_state.dart';
import 'package:learn_english_flutter/ui/saga_hud.dart';

void main() {
  testWidgets('reports the laid-out star counter center', (tester) async {
    Offset? reportedCenter;
    Offset? reportedEnergyCenter;
    final state = ValueNotifier(
      const SagaMapState(progress: 0, currentLevel: 0),
    );
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SagaHud(
            stateListenable: state,
            starPulse: ValueNotifier(0),
            debugVisible: false,
            onDebugPressed: () {},
            onPresetPressed: () {},
            onLevelChanged: (_) {},
            onStarTargetChanged: (center) => reportedCenter = center,
            onEnergyTargetChanged: (center) => reportedEnergyCenter = center,
            onAction: (_, _) {},
            stepCount: 100,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final star = find.byIcon(Icons.star_rounded);
    final starCounter = find.ancestor(
      of: star,
      matching: find.byType(TweenAnimationBuilder<double>),
    );
    final energyCounter = find.ancestor(
      of: find.byIcon(Icons.bolt_rounded),
      matching: find.byType(TweenAnimationBuilder<double>),
    );
    expect(reportedCenter, isNotNull);
    expect(reportedEnergyCenter, isNotNull);
    expect(
      (reportedCenter! - tester.getCenter(starCounter)).distance,
      lessThan(0.1),
    );
    expect(
      (reportedEnergyCenter! - tester.getCenter(energyCounter)).distance,
      lessThan(0.1),
    );
  });

  testWidgets('every visible HUD control responds', (tester) async {
    final actions = <String>[];
    final levelChanges = <int>[];
    var presetChanges = 0;
    var debugChanges = 0;
    final state = ValueNotifier(
      const SagaMapState(progress: 0, currentLevel: 0),
    );
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SagaHud(
            stateListenable: state,
            starPulse: ValueNotifier(0),
            debugVisible: false,
            onDebugPressed: () => debugChanges++,
            onPresetPressed: () => presetChanges++,
            onLevelChanged: levelChanges.add,
            onStarTargetChanged: (_) {},
            onEnergyTargetChanged: (_) {},
            onAction: (title, _) => actions.add(title),
            stepCount: 100,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    for (final tooltip in <String>[
      'Profile',
      'Energy',
      'Stars',
      'Books',
      'Snowflake',
      'Trophy',
      'Lamp',
      'Rewards',
      'Current lesson',
      'Saga map',
      'Lessons',
      'Locked worlds',
      'Practice',
      'Events',
      'More',
    ]) {
      await tester.tap(find.byTooltip(tooltip));
      await tester.pump();
    }
    await tester.tap(find.byTooltip('Go back 1 level'));
    await tester.tap(find.byTooltip('Advance 1 level'));
    await tester.tap(find.byTooltip('Switch path preset'));
    await tester.tap(find.byTooltip('Show debug overlay'));

    expect(actions, hasLength(15));
    expect(levelChanges, [-1, 1]);
    expect(presetChanges, 1);
    expect(debugChanges, 1);
  });
}
