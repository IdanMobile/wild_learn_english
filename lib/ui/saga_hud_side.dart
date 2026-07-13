part of 'saga_hud.dart';

class _SideHudButtons extends StatefulWidget {
  const _SideHudButtons({required this.onAction});

  final SagaHudAction onAction;

  @override
  State<_SideHudButtons> createState() => _SideHudButtonsState();
}

class _SideHudButtonsState extends State<_SideHudButtons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _idle,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            return Stack(
              children: [
                _SideHudButton(
                  left: 22,
                  top: h * 0.34,
                  delay: 0,
                  idleT: _idle.value,
                  idlePhase: 0,
                  imageAsset: 'assets/props/saga_book.png',
                  tooltip: 'Books',
                  onPressed: () => widget.onAction(
                    'Story books',
                    'Your unlocked reading adventures will appear here.',
                  ),
                ),
                _SideHudButton(
                  left: 22,
                  top: h * 0.46,
                  delay: 80,
                  idleT: _idle.value,
                  idlePhase: 0.18,
                  imageAsset: 'assets/props/snowflake.png',
                  tooltip: 'Snowflake',
                  onPressed: () => widget.onAction(
                    'Frozen challenge',
                    'A timed vocabulary challenge is being prepared.',
                  ),
                ),
                _SideHudButton(
                  left: 22,
                  top: h * 0.58,
                  delay: 160,
                  idleT: _idle.value,
                  idlePhase: 0.36,
                  imageAsset: 'assets/props/trophy.png',
                  tooltip: 'Trophy',
                  onPressed: () => widget.onAction(
                    'Achievements',
                    'Complete saga steps and combos to earn trophies.',
                  ),
                ),
                _SideHudButton(
                  right: 22,
                  top: h * 0.34,
                  delay: 60,
                  idleT: _idle.value,
                  idlePhase: 0.54,
                  imageAsset: 'assets/props/magic_lamp.png',
                  tooltip: 'Lamp',
                  onPressed: () => widget.onAction(
                    'Magic lamp',
                    'Your next hint will be available during a lesson.',
                  ),
                ),
                _SideHudButton(
                  right: 22,
                  top: h * 0.46,
                  delay: 140,
                  idleT: _idle.value,
                  idlePhase: 0.72,
                  imageAsset: 'assets/props/gift_box.png',
                  tooltip: 'Rewards',
                  onPressed: () => widget.onAction(
                    'Reward chest',
                    'Collected stars and milestone gifts are stored here.',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SideHudButton extends StatelessWidget {
  const _SideHudButton({
    this.left,
    this.right,
    required this.top,
    required this.delay,
    required this.tooltip,
    required this.imageAsset,
    required this.onPressed,
    required this.idleT,
    required this.idlePhase,
  });

  final double? left;
  final double? right;
  final double top;
  final int delay;
  final String tooltip;
  final String imageAsset;
  final VoidCallback onPressed;
  final double idleT;
  final double idlePhase;

  @override
  Widget build(BuildContext context) {
    // The item gently rocks + bobs; the square underneath stays perfectly
    // straight and still.
    final wave = (idleT + idlePhase) * math.pi * 2;
    final rock = 0.14 * math.sin(wave);
    final bob = 2.5 * math.sin(wave + 0.6);
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 420 + delay),
        curve: Curves.easeOutBack,
        builder: (context, t, child) {
          return Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset((right == null ? -18 : 18) * (1 - t), 0),
              child: Transform.scale(scale: 0.84 + t * 0.16, child: child),
            ),
          );
        },
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none, // let the item spill out of the square
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF9DA7AE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 7,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                // Bigger than the box + tilted, so it overlaps the edges.
                Transform.translate(
                  offset: Offset(0, bob),
                  child: Transform.rotate(
                    angle: rock,
                    child: Image.asset(imageAsset, width: 70, height: 70),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onPressed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
