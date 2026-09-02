import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  required AppColors colors,
  double heightFactor = 0.82,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: colors.overlay,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: heightFactor,
        minChildSize: 0.3,
        maxChildSize: heightFactor,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
                if (title != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
                    child: Text(title,
                        style: GoogleFonts.barlowCondensed(fontSize: 17, fontWeight: FontWeight.w700, color: colors.fg, letterSpacing: 0.5)),
                  ),
                ],
                Expanded(
                  child: SingleChildScrollView(controller: scrollController, child: child),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
