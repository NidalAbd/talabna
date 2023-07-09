import 'package:flutter/material.dart';

class BottomAppBarWidget extends StatefulWidget {
  const BottomAppBarWidget({super.key, required this.icon, required this.name, this.onPressed});
  final Icon icon;
  final String name;
  final void Function()? onPressed;
  @override
  State<BottomAppBarWidget> createState() => _BottomAppBarWidgetState();
}

class _BottomAppBarWidgetState extends State<BottomAppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        IconButton(
          icon: widget.icon,
          onPressed: widget.onPressed,
        ),
        Text(
          widget.name,
          style: const TextStyle(
              color: Colors.white, fontSize: 12),
        )
      ],
    );
  }
}
