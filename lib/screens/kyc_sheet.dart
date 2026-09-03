import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../cubits/kyc_cubit.dart';
import '../cubits/locale_cubit.dart';
import '../features/kyc/domain/repositories/kyc_repository.dart';

class KycSheet extends StatefulWidget {
  final dynamic colors;
  final AppLang lang;
  final bool isRtl;
  const KycSheet({super.key, required this.colors, required this.lang, required this.isRtl});

  @override
  State<KycSheet> createState() => _KycSheetState();
}

class _KycSheetState extends State<KycSheet> {
  final nameCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  bool submitting = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final isRtl = widget.isRtl;
    final lang = widget.lang;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: BlocBuilder<KycCubit, List<KycSubmissionEntity>>(
        builder: (context, submissions) {
          final latest = submissions.isNotEmpty ? submissions.first : null;

          if (latest != null && latest.status != KycStatus.rejected) {
            return _StatusView(submission: latest, colors: colors, isRtl: isRtl);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (latest?.status == KycStatus.rejected) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: colors.loss.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    isRtl ? 'درخواست قبلی رد شد — دوباره تلاش کنید' : 'Previous request was rejected — try again',
                    style: TextStyle(color: colors.loss, fontSize: 12),
                  ),
                ),
              ],
              Text(
                isRtl
                    ? 'برای احراز هویت، نام کامل و کدملی خود را وارد کنید.'
                    : 'To verify your identity, enter your full legal name and national ID.',
                style: TextStyle(color: colors.mutedFg, fontSize: 13),
              ),
              const SizedBox(height: 16),
              AppTextField(label: isRtl ? 'نام کامل' : 'Full name', placeholder: isRtl ? 'نام و نام‌خانوادگی' : 'Full name', controller: nameCtrl, colors: colors, direction: isRtl ? TextDirection.rtl : TextDirection.ltr),
              const SizedBox(height: 16),
              AppTextField(label: isRtl ? 'کد ملی' : 'National ID', placeholder: '0012345678', controller: idCtrl, colors: colors, keyboardType: TextInputType.number, direction: TextDirection.ltr),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: TextStyle(color: colors.loss, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              GradientActionButton.buy(
                label: isRtl ? 'ارسال درخواست' : 'Submit',
                loading: submitting,
                onTap: submitting
                    ? null
                    : () async {
                        if (nameCtrl.text.trim().length < 3 || idCtrl.text.trim().length < 8) {
                          setState(() => error = isRtl ? 'اطلاعات را کامل و صحیح وارد کنید' : 'Please enter valid information');
                          return;
                        }
                        setState(() {
                          submitting = true;
                          error = null;
                        });
                        try {
                          await context.read<KycCubit>().submit(fullName: nameCtrl.text.trim(), nationalId: idCtrl.text.trim());
                        } catch (e) {
                          setState(() => error = e.toString().replaceFirst('Exception: ', ''));
                        } finally {
                          if (mounted) setState(() => submitting = false);
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  final KycSubmissionEntity submission;
  final dynamic colors;
  final bool isRtl;
  const _StatusView({required this.submission, required this.colors, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final isApproved = submission.status == KycStatus.approved;
    return Column(
      children: [
        Icon(
          isApproved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
          size: 48,
          color: isApproved ? colors.gain : colors.buy,
        ),
        const SizedBox(height: 16),
        Text(
          isApproved
              ? (isRtl ? 'احراز هویت شما تأیید شد' : 'Your identity has been verified')
              : (isRtl ? 'درخواست شما در حال بررسی است' : 'Your request is under review'),
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Text(submission.fullName, style: TextStyle(color: colors.mutedFg, fontSize: 12)),
      ],
    );
  }
}
