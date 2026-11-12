import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/operations/widgets/account_selector.dart';
import 'package:iceibank/ui/transfers/view_models/transfer_view_model.dart';
import 'package:iceibank/ui/transfers/widgets/agency_route.dart';

class DestinationStep extends StatefulWidget {
  const DestinationStep({super.key, required this.viewModel});

  final TransferViewModel viewModel;

  @override
  State<DestinationStep> createState() => _DestinationStepState();
}

class _DestinationStepState extends State<DestinationStep> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.viewModel.targetInput,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickSuggestion(int accountId) {
    HapticFeedback.selectionClick();
    _controller.text = '$accountId';
    widget.viewModel.updateTarget('$accountId');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final source = viewModel.source!;
    final targetError = viewModel.targetError;
    final knownTarget = viewModel.knownTarget;
    final suggestions = viewModel.suggestedTargets;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        AccountSelector(
          label: 'Conta de origem',
          accounts: viewModel.accounts,
          selected: source,
          onSelected: viewModel.selectSource,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Para qual conta?',
          style: AppTypography.title2.copyWith(color: context.resolve(AppColors.text)),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: context.resolve(AppColors.surface),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: targetError == null
                  ? const Color(0x00000000)
                  : context.resolve(AppColors.danger),
              width: 1.5,
            ),
          ),
          child: CupertinoTextField(
            controller: _controller,
            onChanged: viewModel.updateTarget,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 9,
            placeholder: 'Número da conta',
            textAlign: TextAlign.center,
            style: AppTypography.amount(30).copyWith(color: context.resolve(AppColors.text)),
            placeholderStyle: AppTypography.title2.copyWith(
              color: context.resolve(AppColors.textTertiary),
            ),
            cursorColor: context.resolve(AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: null,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            targetError ??
                (knownTarget != null
                    ? 'Titular: ${knownTarget.holderName}'
                    : 'Pode ser uma conta de qualquer agência.'),
            key: ValueKey(targetError ?? knownTarget?.id),
            textAlign: TextAlign.center,
            style: AppTypography.footnote.copyWith(
              color: context.resolve(
                targetError == null ? AppColors.textSecondary : AppColors.danger,
              ),
            ),
          ),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final account = suggestions[index];
                final isSelected = account.id == viewModel.targetAccountId;

                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  minimumSize: const Size(0, 36),
                  color: context.resolve(isSelected ? AppColors.primarySoft : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onPressed: () => _pickSuggestion(account.id),
                  child: Text(
                    'Conta ${account.id} · ${account.holderName.split(' ').first}',
                    style: AppTypography.footnote.copyWith(
                      color: context.resolve(isSelected ? AppColors.onPrimarySoft : AppColors.text),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AgencyRoute(
          sourceAgency: viewModel.sourceAgency!,
          targetAgency: viewModel.hasValidTarget ? viewModel.targetAgency : null,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
