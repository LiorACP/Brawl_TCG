import 'package:flutter/material.dart';

class MenuVar extends StatefulWidget {
  const MenuVar({super.key});

  @override
  State<MenuVar> createState() => _MenuVarState();
}

class _MenuVarState extends State<MenuVar> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int selectedIndex = 1;

  final icons = [
    Icons.grid_view,
    Icons.list,
    Icons.bookmark_border,
    Icons.person_outline,
  ];

  void onTap(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: const Center(child: Text("Contenido")),
      bottomNavigationBar: _AnimatedNotchBar(
        selectedIndex: selectedIndex,
        icons: icons,
        onTap: onTap,
      ),
    );
  }
}

class _AnimatedNotchBar extends StatelessWidget {
  final int selectedIndex;
  final List<IconData> icons;
  final Function(int) onTap;

  const _AnimatedNotchBar({
    required this.selectedIndex,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemWidth = width / icons.length;
          final ballX = itemWidth * selectedIndex + itemWidth / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: CustomPaint(
                  size: Size(width, 80),
                  painter: _NavPainter(ballX),
                ),
              ),
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(icons.length, (i) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(i),
                        child: Center(
                          child: selectedIndex == i
                              ? const SizedBox(width: 24)
                              : Icon(icons[i], color: Colors.grey),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: ballX - 25,
                top: -25,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black26)],
                  ),
                  child: Icon(icons[selectedIndex], color: Colors.black),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavPainter extends CustomPainter {
  final double x;
  _NavPainter(this.x);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    const double r = 30;

    path.moveTo(0, 0);
    path.lineTo(x - r * 1.6, 0);
    path.quadraticBezierTo(x - r, 0, x - r, r);
    path.arcToPoint(
      Offset(x + r, r),
      radius: const Radius.circular(r),
      clockwise: false,
    );
    path.quadraticBezierTo(x + r, 0, x + r * 1.6, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black26, 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavPainter oldDelegate) => oldDelegate.x != x;
}
