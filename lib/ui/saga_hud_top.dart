part of 'saga_hud.dart';

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
