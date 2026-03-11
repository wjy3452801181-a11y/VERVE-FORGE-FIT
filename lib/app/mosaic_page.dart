import 'package:go_router/go_router.dart';

import '../shared/widgets/mosaic_transition.dart';

/// 马赛克过渡页面 — 供 GoRouter pageBuilder 使用
class MosaicPage<T> extends CustomTransitionPage<T> {
  MosaicPage({
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return MosaicTransition(
              animation: animation,
              child: child,
            );
          },
        );
}
