import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../cubits/locale_cubit.dart';
import '../../../features/orders/domain/repositories/orders_repository.dart';
import '../../localization/translations.dart';
import '../../theme/context_ext.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatusEntity status;
  final AppLang lang;
  const StatusBadge({super.key, required this.status, required this.lang});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    late Color bg;
    late Color fg;
    late String key;
    switch (status) {
      case OrderStatusEntity.open:
        fg = colors.buy;
        bg = colors.buy.withOpacity(0.12);
        key = 'status_open';
        break;
      case OrderStatusEntity.partiallyFilled:
        fg = colors.sell;
        bg = colors.sell.withOpacity(0.12);
        key = 'status_partially_filled';
        break;
      case OrderStatusEntity.filled:
        fg = colors.gain;
        bg = colors.gain.withOpacity(0.12);
        key = 'status_filled';
        break;
      case OrderStatusEntity.cancelled:
        fg = colors.mutedFg;
        bg = colors.mutedFg.withOpacity(0.12);
        key = 'status_cancelled';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(Tr.t(key, lang), style: GoogleFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
