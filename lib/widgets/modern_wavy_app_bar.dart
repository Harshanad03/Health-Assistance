import 'package:flutter/material.dart';

class ModernWavyAppBar extends StatelessWidget {
  final double height;
  final Widget? child;
  final VoidCallback? onBack;

  const ModernWavyAppBar({
    super.key,
    this.height = 140,
    this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          ClipPath(
            clipper: _ModernWavyClipper(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 1, 25, 59),
                    Color.fromARGB(255, 1, 29, 48),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          if (child != null)
            Positioned.fill(
              child: Align(alignment: Alignment.topCenter, child: child),
            ),

          if (onBack != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                  onPressed: onBack,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModernWavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
