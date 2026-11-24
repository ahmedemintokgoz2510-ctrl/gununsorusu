import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool revealed;
  final bool isCorrect;
  final bool isSelected;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    this.revealed = false,
    this.isCorrect = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg = Colors.transparent;
    Color border = scheme.outlineVariant;
    Color? textColor;
    IconData? icon;

    if (revealed && isCorrect) {
      bg = Colors.green.shade100;
      border = Colors.green;
      textColor = Colors.black87;
      icon = Icons.check_circle;
    } else if (revealed && isSelected) {
      bg = Colors.red.shade100;
      border = Colors.red;
      textColor = Colors.black87;
      icon = Icons.cancel;
    }

    final radius = BorderRadius.circular(12);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(letter, style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ),
                if (icon != null) Icon(icon, color: border),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
