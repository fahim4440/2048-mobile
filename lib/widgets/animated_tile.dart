import 'package:flutter/material.dart';
import '../blocs/game_bloc.dart';

class AnimatedTile extends StatefulWidget {
  final TileData tile;
  final double tileSize;
  final double spacing;

  const AnimatedTile({
    Key? key,
    required this.tile,
    required this.tileSize,
    required this.spacing,
  }) : super(key: key);

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);

    if (widget.tile.isNew) {
      _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutBack,
        ),
      );
      _controller.forward();
    } else if (widget.tile.isMerging) {
      _scaleAnimation = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 0.5),
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 0.5),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.isMerging) {
      _scaleAnimation = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 0.5),
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 0.5),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.blue[100]!;
      case 4:
        return Colors.blue[200]!;
      case 8:
        return Colors.blue[300]!;
      case 16:
        return Colors.blue[400]!;
      case 32:
        return Colors.blue[500]!;
      case 64:
        return Colors.blue[600]!;
      case 128:
        return Colors.blue[700]!;
      case 256:
        return Colors.blue[800]!;
      case 512:
        return Colors.blue[900]!;
      case 1024:
        return Colors.purple[400]!;
      case 2048:
        return Colors.purple[600]!;
      default:
        return Colors.purple[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double top = widget.tile.row * (widget.tileSize + widget.spacing);
    final double left = widget.tile.col * (widget.tileSize + widget.spacing);
    // final double previousTop = widget.tile.previousRow * (widget.tileSize + widget.spacing);
    // final double previousLeft = widget.tile.previousCol * (widget.tileSize + widget.spacing);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.tileSize,
              height: widget.tileSize,
              decoration: BoxDecoration(
                color: _getTileColor(widget.tile.value),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${widget.tile.value}',
                  style: TextStyle(
                    fontSize: widget.tileSize * 0.4,
                    fontWeight: FontWeight.bold,
                    color:
                    widget.tile.value > 4 ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}