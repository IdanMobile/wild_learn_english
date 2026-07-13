part of 'saga_hud.dart';

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
