import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  bool current;
  Widget? trailing;
  Color color;
  MenuTile({
    Key? key,
    required this.title,
    required this.icon,
    this.color = Colors.white,
    this.current = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.maxFinite,
        height: 50.0,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: 5.0,
              color: color,
            ),
            right: current
                ? BorderSide(
                    width: 5.0,
                    color: color,
                  )
                : BorderSide.none,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              trailing ?? Container(),
            ],
          ),
        ),
      ),
    );
  }
}
