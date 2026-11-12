import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/core/widgets/app_message.dart';
import 'package:iceibank/ui/core/widgets/app_status_bar.dart';
import 'package:iceibank/ui/operations/widgets/amount_display.dart';
import 'package:iceibank/ui/operations/widgets/amount_keypad.dart';
import 'package:iceibank/ui/operations/widgets/balance_preview.dart';
import 'package:iceibank/ui/operations/widgets/quick_amounts.dart';
import 'package:iceibank/ui/transfers/view_models/transfer_view_model.dart';
import 'package:iceibank/ui/transfers/widgets/destination_step.dart';
import 'package:iceibank/ui/transfers/widgets/step_progress.dart';
import 'package:iceibank/ui/transfers/widgets/transfer_review.dart';
import 'package:iceibank/ui/transfers/widgets/transfer_success.dart';
import 'package:iceibank/utils/currency.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, required this.accounts, required this.accountRepository});

  final List<Account> accounts;
  final AccountRepository accountRepository;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  static const List<String> _stepLabels = ['Para quem', 'Quanto', 'Confirmar'];

  late final TransferViewModel _viewModel = TransferViewModel(
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

  void _continue() {
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    _viewModel.next();
  }

  Future<void> _submit() async {
    final succeeded = await _viewModel.submit();
    if (succeeded) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final receipt = _viewModel.receipt;
        final isFirstStep = _viewModel.step == TransferStep.destination;

        return PopScope(
          canPop: isFirstStep || receipt != null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _viewModel.back();
          },
          child: AppStatusBar(
            child: CupertinoPageScaffold(
              backgroundColor: context.resolve(AppColors.background),
              navigationBar: CupertinoNavigationBar(
                middle: const Text('Transferir'),
                previousPageTitle: isFirstStep || receipt != null ? 'Início' : 'Voltar',
                automaticallyImplyLeading: receipt == null,
                backgroundColor: context.resolve(AppColors.background),
                border: null,
              ),
              child: SafeArea(
                child: receipt != null
                    ? TransferSuccess(receipt: receipt, onDone: () => Navigator.of(context).pop())
                    : _buildFlow(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlow(BuildContext context) {
    if (_viewModel.source == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.screen),
        child: AppMessage(
          icon: CupertinoIcons.creditcard,
          title: 'Nenhuma conta disponível',
          message: 'É preciso ter ao menos uma conta para transferir.',
        ),
      );
    }

    final step = _viewModel.step;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.lg,
          ),
          child: StepProgress(labels: _stepLabels, current: step.index),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(key: ValueKey(step), child: _buildStep(step)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.md,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: AppButton(
            label: switch (step) {
              TransferStep.review => 'Transferir ${formatCurrency(_viewModel.amount)}',
              _ => 'Continuar',
            },
            isLoading: _viewModel.isSubmitting,
            onPressed: _viewModel.canContinue
                ? (step == TransferStep.review ? _submit : _continue)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(TransferStep step) {
    return switch (step) {
      TransferStep.destination => DestinationStep(viewModel: _viewModel),
      TransferStep.amount => _buildAmountStep(),
      TransferStep.review => TransferReview(viewModel: _viewModel),
    };
  }

  Widget _buildAmountStep() {
    final source = _viewModel.source!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        children: [
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
                BalancePreview(
                  balance: source.balance,
                  resultingBalance: _viewModel.resultingBalance,
                  hasAmount: _viewModel.amount > 0,
                  isOverdrawn: _viewModel.isOverdrawn,
                ),
                const SizedBox(height: AppSpacing.lg),
                QuickAmounts(
                  balance: source.balance,
                  includeAll: true,
                  enabled: true,
                  onSelected: (value) {
                    HapticFeedback.selectionClick();
                    _viewModel.setAmount(value);
                  },
                ),
              ],
            ),
          ),
          AmountKeypad(
            onDigit: _onDigit,
            onBackspace: _viewModel.removeDigit,
            onClear: _viewModel.clearAmount,
          ),
        ],
      ),
    );
  }
}
