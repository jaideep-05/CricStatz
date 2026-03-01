import 'dart:math';

import 'package:cricstatz/config/assets.dart';
import 'package:flutter/material.dart';

class CoinFlipWidget extends StatefulWidget {
  const CoinFlipWidget({super.key});

  @override
  State<CoinFlipWidget> createState() => CoinFlipWidgetState();
}

class CoinFlipWidgetState extends State<CoinFlipWidget>
    with TickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final AnimationController _bounceCtrl;
  late final AnimationController _glowCtrl;

  late Animation<double> _rotationAnim;
  late Animation<double> _heightAnim;
  late Animation<double> _scaleAnim;

  bool _isFlipping = false;
  bool resultHeads = true;
  bool hasFlipped = false;
  bool _showFallback = false;

  static const double coinSize = 160.0;
  static const double _maxHeight = 220.0;

  final _rng = Random();

  @override
  void initState() {
    super.initState();

    _flipCtrl = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _bounceCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _glowCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buildAnims(0);

    _flipCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _bounceCtrl.forward(from: 0).then((_) {
          if (mounted) _glowCtrl.forward(from: 0);
        });
      }
    });
  }

  void _buildAnims(double target) {
    _rotationAnim = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeOutCubic),
    );

    _heightAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: _maxHeight)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: _maxHeight, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 65,
      ),
    ]).animate(_flipCtrl);

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 65,
      ),
    ]).animate(_flipCtrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precache();
  }

  Future<void> _precache() async {
    try {
      if (!mounted) return;
      await precacheImage(AssetImage(AppAssets.coinHeads), context);
      if (!mounted) return;
      await precacheImage(AssetImage(AppAssets.coinTails), context);
    } catch (_) {
      if (mounted) setState(() => _showFallback = true);
    }
  }

  /// Starts the coin flip. Returns true for heads, false for tails.
  Future<bool> flip() async {
    if (_isFlipping) return resultHeads;

    resultHeads = _rng.nextBool();

    // 6 full rotations (12*pi). Add pi for tails so it lands face-down.
    final target = 12 * pi + (resultHeads ? 0.0 : pi);
    _buildAnims(target);

    setState(() {
      _isFlipping = true;
      hasFlipped = false;
    });

    _flipCtrl.reset();
    _bounceCtrl.reset();
    _glowCtrl.reset();

    await _flipCtrl.forward();

    // Wait for bounce + glow to finish
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isFlipping = false;
        hasFlipped = true;
      });
    }

    return resultHeads;
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _bounceCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: coinSize + _maxHeight + 30,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipCtrl, _bounceCtrl, _glowCtrl]),
        builder: (context, _) {
          final angle = _rotationAnim.value;
          final height = _flipCtrl.isAnimating ? _heightAnim.value : 0.0;
          final scale = _flipCtrl.isAnimating ? _scaleAnim.value : 1.0;

          // Damped bounce oscillation after main flip lands
          final bounce = _bounceCtrl.isAnimating
              ? sin(_bounceCtrl.value * pi * 3) *
                  10 *
                  (1 - _bounceCtrl.value)
              : 0.0;

          final totalUp = height + bounce;

          // Face swap: cos(angle) >= 0 → front (heads), < 0 → back (tails)
          final showHeads = cos(angle) >= 0;

          // Shadow shrinks & fades as coin rises
          final shadowK =
              (1 - height / _maxHeight * 0.7).clamp(0.0, 1.0);

          // Glow ring after landing
          final glow = _glowCtrl.value;
          final glowColor = resultHeads
              ? const Color(0xFFFFD700)
              : const Color(0xFFC0C0C0);

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Shadow ellipse
              Positioned(
                bottom: 0,
                child: Opacity(
                  opacity: shadowK,
                  child: Container(
                    width: coinSize * 0.55 * shadowK,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),

              // Glow ring
              if (glow > 0)
                Positioned(
                  bottom: 10 + coinSize / 2 - 70,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              glowColor.withValues(alpha: 0.5 * glow),
                          blurRadius: 36 * glow,
                          spreadRadius: 8 * glow,
                        ),
                      ],
                    ),
                  ),
                ),

              // The coin — rotateX for realistic vertical toss
              Positioned(
                bottom: 10 + totalUp,
                child: Transform.scale(
                  scale: scale,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(angle),
                    child: SizedBox(
                      width: coinSize,
                      height: coinSize,
                      child: _face(showHeads),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _face(bool isHeads) {
    if (_showFallback) return _fallback(isHeads);

    final asset = isHeads ? AppAssets.coinHeads : AppAssets.coinTails;

    Widget img = Image.asset(
      asset,
      width: coinSize,
      height: coinSize,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showFallback = true);
        });
        return _fallback(isHeads);
      },
    );

    // When showing tails (back face), counter-rotate by pi around X
    // to prevent the image from appearing upside-down
    if (!isHeads) {
      img = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(pi),
        child: img,
      );
    }

    return img;
  }

  Widget _fallback(bool isHeads) {
    return Container(
      width: coinSize,
      height: coinSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isHeads ? const Color(0xFFFFD700) : const Color(0xFFC0C0C0),
      ),
      child: Center(
        child: Text(
          isHeads ? 'H' : 'T',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
