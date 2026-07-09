import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'saga_map_game.dart';

class SagaMapScreen extends StatelessWidget {
  const SagaMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recovery-Governance Exception 1 (additive only): the blank Scaffold stub
    // is composed with, not replaced — GameWidget goes in its body.
    return Scaffold(
      body: GameWidget.controlled(gameFactory: SagaMapGame.new),
    );
  }
}
