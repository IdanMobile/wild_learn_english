import 'saga_node_state.dart';

class SagaNode {
  const SagaNode({
    required this.index,
    required this.x,
    required this.depth,
    required this.state,
  });

  final int index;
  final double x;
  final int depth;
  final SagaNodeState state;
}
