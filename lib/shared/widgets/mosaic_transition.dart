import 'dart:math';
import 'package:flutter/material.dart';

/// 马赛克过渡动画组件
/// 白色方块网格覆盖层，方块随机消失以展现下层页面
class MosaicTransition extends StatefulWidget {
  final Animation<double> animation;
  final Widget child;
  final int cols;
  final int rows;

  const MosaicTransition({
    super.key,
    required this.animation,
    required this.child,
    this.cols = 10,
    this.rows = 8,
  });

  @override
  State<MosaicTransition> createState() => _MosaicTransitionState();
}

class _MosaicTransitionState extends State<MosaicTransition> {
  late List<int> _order;

  @override
  void initState() {
    super.initState();
    _buildOrder();
  }

  @override
  void didUpdateWidget(MosaicTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cols != widget.cols || oldWidget.rows != widget.rows) {
      _buildOrder();
    }
  }

  void _buildOrder() {
    final total = widget.cols * widget.rows;
    _order = List.generate(total, (i) => i)..shuffle(Random(42));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: widget.animation,
          builder: (context, _) {
            return IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellW = constraints.maxWidth / widget.cols;
                  final cellH = constraints.maxHeight / widget.rows;
                  final total = widget.cols * widget.rows;
                  final progress = widget.animation.value;

                  return Stack(
                    children: List.generate(total, (i) {
                      final threshold = _order[i] / total;
                      final visible = progress <= threshold;

                      if (!visible) return const SizedBox.shrink();

                      final col = i % widget.cols;
                      final row = i ~/ widget.cols;

                      return Positioned(
                        left: col * cellW,
                        top: row * cellH,
                        width: cellW + 0.5,
                        height: cellH + 0.5,
                        child: const ColoredBox(color: Colors.white),
                      );
                    }),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
