import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/common/widgets/coin_icon.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_ext.dart';
import '../cubits/deposit_cubit.dart';
import '../cubits/locale_cubit.dart';
import '../data/mock_data.dart';
import '../features/deposit/domain/repositories/deposit_repository.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});
  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  Coin selectedCoin = kCoins.first;
  late String selectedNetwork = kCoinNetworks[selectedCoin.id]!.first;
  bool copied = false;
  String? address;
  bool loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    setState(() => loadingAddress = true);
    try {
      final addr = await context.read<DepositCubit>().getAddress(coinSymbol: selectedCoin.id, network: selectedNetwork);
      if (mounted) setState(() => address = addr);
    } catch (_) {
      if (mounted) setState(() => address = null);
    } finally {
      if (mounted) setState(() => loadingAddress = false);
    }
  }

  void _selectCoin(Coin c) {
    setState(() {
      selectedCoin = c;
      selectedNetwork = kCoinNetworks[c.id]!.first;
      address = null;
    });
    _loadAddress();
  }

  void _selectNetwork(String net) {
    setState(() {
      selectedNetwork = net;
      address = null;
    });
    _loadAddress();
  }

  void _copy() {
    if (address == null) return;
    Clipboard.setData(ClipboardData(text: address!));
    setState(() => copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => copied = false);
    });
  }

  void _submitDemoDeposit() {
    context.read<DepositCubit>().submit(coinSymbol: selectedCoin.id, network: selectedNetwork, amount: 100);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.lang;
    final isRtl = context.isRtl;
    final networks = kCoinNetworks[selectedCoin.id]!;
    final deposits = context.watch<DepositCubit>().state;
    final relevantDeposits = deposits.where((d) => d.coinSymbol == selectedCoin.id && d.network == selectedNetwork).toList();
    final latest = relevantDeposits.isNotEmpty ? relevantDeposits.first : null;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: colors.bg,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Tr.t('deposit', lang), style: AppFonts.display(color: colors.fg, size: 24, weight: FontWeight.w900)),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    Text(Tr.t('selectCoin', lang).toUpperCase(), style: AppFonts.display(color: colors.mutedFg, size: 10, letterSpacing: 0.2)),
                    const SizedBox(height: 8),
                    Row(
                      children: kCoins
                          .map((c) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: GestureDetector(
                                    onTap: () => _selectCoin(c),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: selectedCoin.id == c.id ? colors.buy.withOpacity(0.1) : colors.muted,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: selectedCoin.id == c.id ? colors.buy : colors.border),
                                      ),
                                      child: Column(
                                        children: [
                                          CoinIcon(id: c.id, size: 28),
                                          const SizedBox(height: 4),
                                          Text(c.id, style: AppFonts.display(color: colors.fg, size: 12, weight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(Tr.t('selectNetwork', lang).toUpperCase(), style: AppFonts.display(color: colors.mutedFg, size: 10, letterSpacing: 0.2)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: networks
                          .map((net) => GestureDetector(
                                onTap: () => _selectNetwork(net),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedNetwork == net ? colors.buy : colors.muted,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: selectedNetwork == net ? colors.buy : colors.border),
                                  ),
                                  child: Text(net, style: AppFonts.mono(color: selectedNetwork == net ? Colors.black : colors.mutedFg, size: 12, weight: FontWeight.w700)),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(Tr.t('depositAddr', lang).toUpperCase(), style: AppFonts.display(color: colors.mutedFg, size: 10, letterSpacing: 0.2)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: colors.border)),
                      child: Column(
                        children: [
                          if (loadingAddress)
                            const SizedBox(height: 180, width: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: QrImageView(
                                data: address ?? selectedCoin.id,
                                version: QrVersions.auto,
                                size: 180,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
                            child: Text(
                              address ?? (isRtl ? 'در حال دریافت آدرس...' : 'Fetching address...'),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.ltr,
                              style: AppFonts.mono(color: colors.fg, size: 12),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ChromeButton(
                              label: copied ? Tr.t('copied', lang) : Tr.t('copyAddr', lang),
                              colors: colors,
                              onTap: address != null ? _copy : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: colors.sell.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.sell.withOpacity(0.2))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 18, color: colors.sell),
                          const SizedBox(width: 10),
                          Expanded(child: Text(Tr.t('depositNote', lang), style: TextStyle(color: colors.sell, fontSize: 12, height: 1.4))),
                        ],
                      ),
                    ),
                    if (latest != null) ...[
                      const SizedBox(height: 16),
                      _DepositStatusCard(deposit: latest, colors: colors, lang: lang, isRtl: isRtl),
                    ],
                    const SizedBox(height: 16),
                    GradientActionButton.buy(
                      label: isRtl ? 'شبیه‌سازی واریز ۱۰۰ واحدی (دمو)' : 'Simulate 100-unit Deposit (Demo)',
                      onTap: address != null ? _submitDemoDeposit : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepositStatusCard extends StatelessWidget {
  final DepositEntity deposit;
  final dynamic colors;
  final AppLang lang;
  final bool isRtl;
  const _DepositStatusCard({required this.deposit, required this.colors, required this.lang, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final stepIndex = switch (deposit.status) {
      DepositStatusEntity.pending => 0,
      DepositStatusEntity.confirming => 1,
      DepositStatusEntity.completed => 2,
    };
    final stepLabels = [Tr.t('pending', lang), Tr.t('confirming', lang), Tr.t('completed', lang)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: colors.border)),
      child: Column(
        children: [
          Text(isRtl ? 'وضعیت تراکنش' : 'Transaction Status', style: AppFonts.display(color: colors.fg, size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(stepLabels.length * 2 - 1, (i) {
              if (i.isOdd) {
                final lineIndex = i ~/ 2;
                final done = lineIndex < stepIndex;
                return Container(width: 32, height: 2, color: done ? colors.gain : colors.border, margin: const EdgeInsets.symmetric(horizontal: 4));
              }
              final idx = i ~/ 2;
              final done = idx < stepIndex;
              final active = idx == stepIndex;
              return Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? colors.gain : (active ? colors.buy : colors.muted),
                      border: Border.all(color: done ? colors.gain : (active ? colors.buy : colors.border), width: 2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(stepLabels[idx], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: done ? colors.gain : (active ? colors.buy : colors.mutedFg))),
                ],
              );
            }),
          ),
          if (deposit.status == DepositStatusEntity.confirming) ...[
            const SizedBox(height: 10),
            Text('${deposit.confirmations}/${deposit.requiredConfirmations} ${isRtl ? 'تأیید' : 'confirmations'}',
                style: AppFonts.mono(color: colors.buy, size: 12, weight: FontWeight.w700)),
          ],
          if (deposit.status == DepositStatusEntity.completed) ...[
            const SizedBox(height: 10),
            Text(isRtl ? '✓ واریز با موفقیت انجام شد' : '✓ Deposit successful', style: TextStyle(color: colors.gain, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}
