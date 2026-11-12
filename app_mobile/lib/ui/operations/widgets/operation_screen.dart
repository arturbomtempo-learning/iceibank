import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/core/widgets/app_message.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/ui/core/widgets/app_status_bar.dart';
import 'package:iceibank/ui/operations/view_models/operation_view_model.dart';
import 'package:iceibank/ui/operations/widgets/account_selector.dart';
import 'package:iceibank/ui/operations/widgets/amount_display.dart';
import 'package:iceibank/ui/operations/widgets/amount_keypad.dart';
import 'package:iceibank/ui/operations/widgets/operation_success.dart';
import 'package:iceibank/utils/currency.dart';

class OperationScreen extends StatefulWidget {
  const OperationScreen({
    super.key,
    required this.type,
    required this.accounts,
    required this.accountRepository,
  });

  final OperationType type;
  final List<Account> accounts;
  final AccountRepository accountRepository;

  @override
  State<OperationScreen> createState() => _OperationScreenState();
}

class _OperationScreenState extends State<OperationScreen> {
  late final OperationViewModel _viewModel = OperationViewModel(
    type: widget.type,
    accounts: widget.accounts,
    accountRepository: widget.accountRepository,
  );

  int _shakeSignal = 0;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _rejectInput() {
    HapticFeedback.heavyImpact();
    setState(() => _shakeSignal++);
  }

  void _onDigit(int digit) {
    final wasOverdrawn = _viewModel.isOverdrawn;
    final accepted = _viewModel.appendDigit(digit);

    if (!accepted || (!wasOverdrawn && _viewModel.isOverdrawn)) _rejectInput();
  }

  void _onQuickAmount(double value) {
    HapticFeedback.selectionClick();
    _viewModel.setAmount(value);
  }

  Future<void> _submit() async {
    final succeeded = await _viewModel.submit();

    if (succeeded) {
      await HapticFeedback.mediumImpact();
    } else if (_viewModel.errorMessage != null) {
      _rejectInput();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStatusBar(
      child: CupertinoPageScaffold(
        backgroundColor: context.resolve(AppColors.background),
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.type.title),
          previousPageTitle: 'Início',
          backgroundColor: context.resolve(AppColors.background),
          border: null,
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final receipt = _viewModel.receipt;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: receipt != null
                    ? OperationSuccess(
                        key: const ValueKey('success'),
                        type: widget.type,
                        receipt: receipt,
                        onDone: () => Navigator.of(context).pop(),
                        onAnother: _viewModel.startAnother,
                      )
                    : KeyedSubtree(key: const ValueKey('form'), child: _buildForm(context)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final account = _viewModel.selectedAccount;

    if (account == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: AppMessage(
          icon: CupertinoIcons.creditcard,
          title: 'Nenhuma conta disponível',
          message: widget.type == OperationType.deposit
              ? 'É preciso ter ao menos uma conta para depositar.'
              : 'É preciso ter ao menos uma conta para sacar.',
        ),
      );
    }

    final amount = _viewModel.amount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          AccountSelector(
            label: widget.type.accountLabel,
            accounts: _viewModel.accounts,
            selected: account,
            enabled: !_viewModel.isSubmitting,
            onSelected: _viewModel.selectAccount,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AmountDisplay(
                  amountInCents: _viewModel.amountInCents,
                  isInvalid: _viewModel.isOverdrawn,
                  shakeSignal: _shakeSignal,
                ),
                const SizedBox(height: AppSpacing.sm),
                _BalancePreview(
                  balance: account.balance,
                  resultingBalance: _viewModel.resultingBalance ?? account.balance,
                  hasAmount: amount > 0,
                  isOverdrawn: _viewModel.isOverdrawn,
                ),
                const SizedBox(height: AppSpacing.lg),
                _QuickAmounts(
                  type: widget.type,
                  balance: account.balance,
                  enabled: !_viewModel.isSubmitting,
                  onSelected: _onQuickAmount,
                ),
                if (_viewModel.errorMessage case final message?) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppNotice(message: message, tone: AppNoticeTone.danger),
                ],
              ],
            ),
          ),
          AmountKeypad(
            enabled: !_viewModel.isSubmitting,
            onDigit: _onDigit,
            onBackspace: _viewModel.removeDigit,
            onClear: _viewModel.clearAmount,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: amount > 0
                ? '${widget.type.title} ${formatCurrency(amount)}'
                : widget.type.title,
            isLoading: _viewModel.isSubmitting,
            onPressed: _viewModel.canSubmit ? _submit : null,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _BalancePreview extends StatelessWidget {
  const _BalancePreview({
    required this.balance,
    required this.resultingBalance,
    required this.hasAmount,
    required this.isOverdrawn,
  });

  final double balance;
  final double resultingBalance;
  final bool hasAmount;
  final bool isOverdrawn;

  @override
  Widget build(BuildContext context) {
    final secondary = context.resolve(AppColors.textSecondary);
    final style = AppTypography.subheadline.copyWith(color: secondary);

    if (isOverdrawn) {
      return Text(
        'Saldo insuficiente. Disponível: ${formatCurrency(balance)}',
        textAlign: TextAlign.center,
        style: style.copyWith(color: context.resolve(AppColors.danger)),
      );
    }

    if (!hasAmount) {
      return Text('Saldo atual ${formatCurrency(balance)}', style: style);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(formatCurrency(balance), style: style),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(CupertinoIcons.arrow_right, size: 14, color: secondary),
        ),
        Text(
          formatCurrency(resultingBalance),
          style: style.copyWith(
            color: context.resolve(AppColors.text),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuickAmounts extends StatelessWidget {
  const _QuickAmounts({
    required this.type,
    required this.balance,
    required this.enabled,
    required this.onSelected,
  });

  final OperationType type;
  final double balance;
  final bool enabled;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(String, double)>[
      ('R\$ 50', 50),
      ('R\$ 100', 100),
      ('R\$ 200', 200),
      if (type == OperationType.withdraw && balance > 0) ('Tudo', balance),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final (label, value) in options)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            minimumSize: const Size(0, 34),
            color: context.resolve(AppColors.surface),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onPressed: enabled ? () => onSelected(value) : null,
            child: Text(
              label,
              style: AppTypography.footnote.copyWith(
                color: context.resolve(AppColors.primary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
