import 'package:flutter/material.dart';

class CustomSectionCard extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? headerAction;
  final bool isExpanded;

  const CustomSectionCard({
    super.key,
    required this.title,
    required this.content,
    this.headerAction,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // 3D effect
      shadowColor: Colors.black26, // Softer shadow
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8), // Spacing between cards
      child: Theme(
        // remove default top/bottom borders of ExpansionTile
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          trailing: headerAction, // Custom action or default arrow if null?
          // If headerAction is null, ExpansionTile shows an arrow by default.
          // If headerAction is provided, it REPLACES the arrow.
          // User might want arrow AND action, but typically 'trailing' is one widget.
          // We'll pass headerAction directly. If user wants arrow + action they can pass a Row.
          // But our ProfileScreen uses headerAction mainly for empty states or specialized controls if any.
          // Actually in previous refactor we removed most headerActions (edit/save).
          // So mostly this will be null and show default chevron.

          childrenPadding:
              const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          children: [
            // Underline below header (Divider)
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFEEEEEE), // Light grey
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}
