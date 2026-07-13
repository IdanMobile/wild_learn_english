import 'package:flutter/material.dart';

import '../saga_map/saga_map_screen.dart';

class SagaApp extends StatelessWidget {
  const SagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SagaMapScreen());
  }
}
