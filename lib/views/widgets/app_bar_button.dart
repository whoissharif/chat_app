import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  const AppBarButton({Key? key, required this.icon, required this.ontap})
      : super(key: key);

  final IconData icon;
  final Function ontap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ontap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
