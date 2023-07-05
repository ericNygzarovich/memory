import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_of_guess_the_color/bloc/memore_bloc_bloc.dart';

class GameItem extends StatefulWidget {
  final int i;
  final int j;
  final Color color;
  const GameItem({
    super.key,
    required this.color,
    required this.i,
    required this.j,
  });

  @override
  State<GameItem> createState() => _GameItemState();
}

class _GameItemState extends State<GameItem> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _collapsesValue;
  late Animation<double> _reversValue;
  bool _isEquals = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _collapsesValue =
        Tween<double>(begin: 1, end: 0).animate(_animationController)
          ..addListener(() {
            setState(() {});
          });

    _reversValue = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  Future<void> runAnimation() async {
    _animationController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));

    _animationController.reverse();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          double angle = _reversValue.value * -pi;

          Matrix4 revers = Matrix4.identity()..scale(_collapsesValue.value);
          Matrix4 collapse = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform(
                  transform: _isEquals ? revers : collapse,
                  alignment: FractionalOffset.center,
                  child: InkWell(
                    onTap: () {
                      runAnimation();
                      context.read<MemoreBlocBloc>().add(
                            ShowColorMemoreBlocEvent(
                              color: widget.color,
                              i: widget.i,
                              j: widget.j,
                            ),
                          );
                    },
                    child: Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        color: _reversValue.value > 0.5
                            ? Colors.orange
                            : widget.color,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}