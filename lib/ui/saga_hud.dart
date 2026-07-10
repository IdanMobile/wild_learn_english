import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../saga_map/domain/saga_map_state.dart';

typedef SagaHudAction = void Function(String title, String message);

class SagaHud extends StatelessWidget {
  const SagaHud({
    super.key,
    required this.stateListenable,
    required this.starPulse,
    required this.debugVisible,
    required this.onDebugPressed,
    required this.onPresetPressed,
    required this.onLevelChanged,
    required this.onStarTargetChanged,
    required this.onEnergyTargetChanged,
    required this.onAction,
    required this.stepCount,
  });

  final ValueNotifier<SagaMapState> stateListenable;
  final ValueListenable<int> starPulse;
  final bool debugVisible;
  final VoidCallback onDebugPressed;
  final VoidCallback onPresetPressed;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<Offset> onStarTargetChanged;
  final ValueChanged<Offset> onEnergyTargetChanged;
  final SagaHudAction onAction;
  final int? stepCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SagaMapState>(
      valueListenable: stateListenable,
      builder: (context, state, _) {
        return Stack(
          children: [
            _SideHudButtons(onAction: onAction),
            _TopHud(
              level: state.currentLevel,
              energy: state.energy,
              stars: state.stars,
              starPulse: starPulse,
              debugVisible: debugVisible,
              onDebugPressed: onDebugPressed,
              onPresetPressed: onPresetPressed,
              onLevelChanged: onLevelChanged,
              onStarTargetChanged: onStarTargetChanged,
              onEnergyTargetChanged: onEnergyTargetChanged,
              onAction: onAction,
            ),
            _LessonCard(
              level: state.currentLevel,
              stepCount: stepCount,
              onPressed: () => onAction(
                'Current lesson',
                'Chapter ${state.currentLevel ~/ 10 + 1}, lesson ${state.currentLevel % 10 + 1}. Tap the glowing map stone to begin.',
              ),
            ),
            _BottomNav(onAction: onAction),
          ],
        );
      },
    );
  }
}

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

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.level,
    required this.energy,
    required this.stars,
    required this.starPulse,
    required this.debugVisible,
    required this.onDebugPressed,
    required this.onPresetPressed,
    required this.onLevelChanged,
    required this.onStarTargetChanged,
    required this.onEnergyTargetChanged,
    required this.onAction,
  });

  final int level;
  final int energy;
  final int stars;
  final ValueListenable<int> starPulse;
  final bool debugVisible;
  final VoidCallback onDebugPressed;
  final VoidCallback onPresetPressed;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<Offset> onStarTargetChanged;
  final ValueChanged<Offset> onEnergyTargetChanged;
  final SagaHudAction onAction;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      right: 10,
      top: 10 + MediaQuery.paddingOf(context).top,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 400;
          final gap = compact ? 6.0 : 8.0;

          return Row(
            children: [
              Tooltip(
                message: 'Profile',
                child: InkWell(
                  onTap: () => onAction(
                    'Profile',
                    'Your learner profile and avatar will appear here.',
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: compact ? 54 : 64,
                    height: compact ? 54 : 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x22A8C3CC)),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF9AB0BA),
                    ),
                  ),
                ),
              ),
              SizedBox(width: gap),
              _CounterPill(
                icon: Icons.bolt_rounded,
                tooltip: 'Energy',
                iconColor: Color(0xFF21AFFF),
                value: '$energy',
                compact: compact,
                pulseKey: energy,
                onCenterChanged: onEnergyTargetChanged,
                onPressed: () => onAction(
                  'Energy',
                  '$energy energy available. Completing a step restores energy.',
                ),
              ),
              SizedBox(width: gap),
              // Pulses both when the count changes and when a bar's reward
              // stars land (starPulse), so it reacts as stars arrive.
              ValueListenableBuilder<int>(
                valueListenable: starPulse,
                builder: (context, pulse, _) => _CounterPill(
                  icon: Icons.star_rounded,
                  tooltip: 'Stars',
                  iconColor: const Color(0xFFFFC83D),
                  value: '$stars',
                  compact: compact,
                  pulseKey: Object.hash(stars, pulse),
                  onCenterChanged: onStarTargetChanged,
                  onPressed: () => onAction(
                    'Stars',
                    '$stars stars collected. Reward stars arrive here after each completed step.',
                  ),
                ),
              ),
              const Spacer(),
              _TinyButton(
                label: '-',
                tooltip: 'Go back 1 level',
                onPressed: () => onLevelChanged(-1),
                compact: compact,
              ),
              SizedBox(width: gap),
              _TinyButton(
                label: '+',
                tooltip: 'Advance 1 level',
                onPressed: () => onLevelChanged(1),
                compact: compact,
              ),
              SizedBox(width: gap),
              _RoundButton(
                icon: Icons.route_rounded,
                tooltip: 'Switch path preset',
                onPressed: onPresetPressed,
                compact: compact,
              ),
              SizedBox(width: gap),
              _RoundButton(
                icon: debugVisible ? Icons.visibility_off : Icons.visibility,
                tooltip: debugVisible
                    ? 'Hide debug overlay'
                    : 'Show debug overlay',
                onPressed: onDebugPressed,
                compact: compact,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TinyButton extends StatelessWidget {
  const _TinyButton({
    required this.label,
    required this.tooltip,
    required this.onPressed,
    required this.compact,
  });

  final String label;
  final String tooltip;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 34.0;

    return SizedBox(
      width: size,
      height: size,
      child: Tooltip(
        message: tooltip,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            foregroundColor: const Color(0xFF5C7481),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 18 : 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterPill extends StatefulWidget {
  const _CounterPill({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.value,
    required this.compact,
    required this.pulseKey,
    this.onCenterChanged,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final String value;
  final bool compact;
  final int pulseKey;
  final ValueChanged<Offset>? onCenterChanged;
  final VoidCallback? onPressed;

  @override
  State<_CounterPill> createState() => _CounterPillState();
}

class _CounterPillState extends State<_CounterPill> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.onCenterChanged == null) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        widget.onCenterChanged!(
          box.localToGlobal(box.size.center(Offset.zero)),
        );
      }
    });

    return Tooltip(
      message: widget.tooltip,
      child: TweenAnimationBuilder<double>(
        key: ValueKey('${widget.value}-${widget.pulseKey}'),
        tween: Tween(begin: 1.16, end: 1),
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: SizedBox(
          width: widget.compact ? 58 : 64,
          height: widget.compact ? 32 : 34,
          child: Material(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 6 : 8,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: widget.compact ? 22 : 24,
                      ),
                      SizedBox(width: widget.compact ? 3 : 5),
                      Text(
                        widget.value,
                        style: TextStyle(
                          color: const Color(0xFF5C7481),
                          fontWeight: FontWeight.w800,
                          fontSize: widget.compact ? 14 : 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.compact,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 44.0;

    return SizedBox(
      width: size,
      height: size,
      child: IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF8B64D9),
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon, size: compact ? 21 : 23),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.level,
    required this.stepCount,
    required this.onPressed,
  });

  final int level;
  final int? stepCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final chapter = level ~/ 10 + 1;
    final lesson = level % 10 + 1;
    return Positioned(
      left: 10,
      right: 10,
      bottom: 86,
      child: Tooltip(
        message: 'Current lesson',
        child: Material(
          color: const Color(0xFFF4EFF1).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CHAPTER $chapter',
                    style: const TextStyle(
                      color: Color(0xFF657985),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'LESSON $lesson  •  SAGA STEP $level',
                    style: const TextStyle(
                      color: Color(0xFF74858E),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stepCount == null
                        ? '${level + 1}/∞'
                        : '${level + 1}/$stepCount',
                    style: const TextStyle(
                      color: Color(0xFF87949A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onAction});

  final SagaHudAction onAction;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, Color(0xFFFF4F65), 'Saga map'),
      (Icons.menu_book_rounded, Color(0xFFE8B35D), 'Lessons'),
      (Icons.lock_rounded, Color(0xFFFF7EB6), 'Locked worlds'),
      (Icons.forum_rounded, Color(0xFF57D65E), 'Practice'),
      (Icons.confirmation_number_rounded, Color(0xFFFF6868), 'Events'),
      (Icons.menu_rounded, Color(0xFF5ED95F), 'More'),
    ];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 76,
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final item in items)
              IconButton(
                tooltip: item.$3,
                onPressed: () => onAction(
                  item.$3,
                  item.$3 == 'Saga map'
                      ? 'You are already exploring the saga map.'
                      : '${item.$3} is coming soon. This preview is ready for the next feature wave.',
                ),
                icon: Icon(item.$1, color: item.$2, size: 30),
              ),
          ],
        ),
      ),
    );
  }
}
