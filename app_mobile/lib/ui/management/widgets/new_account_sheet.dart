import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/widgets/animated_check.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/ui/core/widgets/app_text_field.dart';
import 'package:iceibank/ui/core/widgets/fade_slide_in.dart';
import 'package:iceibank/ui/home/widgets/account_card.dart';
import 'package:iceibank/ui/management/view_models/new_account_view_model.dart';
import 'package:iceibank/ui/management/widgets/management_sheet.dart';
import 'package:iceibank/utils/currency.dart';
import 'package:iceibank/utils/currency_input_formatter.dart';
import 'package:iceibank/utils/text_formatters.dart';

Future<bool?> showNewAccountSheet(
  BuildContext context, {
  required AccountRepository repository,
  String initialOwner = '',
}) {
  return showCupertinoSheet<bool>(
    context: context,
    scrollableBuilder: (context, scrollController) => NewAccountSheet(
      repository: repository,
      initialOwner: initialOwner,
      scrollController: scrollController,
    ),
  );
}

class NewAccountSheet extends StatefulWidget {
  const NewAccountSheet({
    super.key,
    required this.repository,
    required this.initialOwner,
    required this.scrollController,
  });

  final AccountRepository repository;
  final String initialOwner;
  final ScrollController scrollController;

  @override
  State<NewAccountSheet> createState() => _NewAccountSheetState();
}

class _NewAccountSheetState extends State<NewAccountSheet> {
  late final NewAccountViewModel _viewModel = NewAccountViewModel(
    accountRepository: widget.repository,
    initialOwner: widget.initialOwner,
  );

  final _accountController = TextEditingController();
  final _holderController = TextEditingController();
  late final _ownerController = TextEditingController(text: widget.initialOwner);
  final _balanceController = TextEditingController();

  final _holderFocusNode = FocusNode();
  final _ownerFocusNode = FocusNode();
  final _balanceFocusNode = FocusNode();

  @override
  void dispose() {
    _viewModel.dispose();
    for (final controller in [
      _accountController,
      _holderController,
      _ownerController,
      _balanceController,
    ]) {
      controller.dispose();
    }
    for (final node in [_holderFocusNode, _ownerFocusNode, _balanceFocusNode]) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await _viewModel.submit();

    if (_viewModel.createdAccount != null) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  String? get _agencyHint {
    final accountId = _viewModel.accountId;
    final agencyId = _viewModel.agencyId;
    if (accountId == null || agencyId == null) {
      return 'O número define a agência que vai guardar a conta.';
    }
    return 'Vai para a Agência $agencyId ($accountId % ${AgencyEndpoints.count} = $agencyId).';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final created = _viewModel.createdAccount;

        if (created != null) {
          return ManagementSheet(
            title: 'Abrir conta',
            scrollController: widget.scrollController,
            canCancel: false,
            footer: AppButton(label: 'Concluir', onPressed: () => Navigator.of(context).pop(true)),
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Center(child: AnimatedCheck()),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                child: SheetSuccess(
                  title: 'Conta aberta',
                  message:
                      'Conta ${created.id} criada para ${created.holderName} com '
                      '${formatCurrency(created.balance)} na Agência ${created.agencyId}.',
                  highlight: AccountCard(account: created, isBalanceVisible: true),
                ),
              ),
            ],
          );
        }

        final formError = _viewModel.formError;

        return ManagementSheet(
          title: 'Abrir conta',
          scrollController: widget.scrollController,
          footer: AppButton(
            label: 'Abrir conta',
            isLoading: _viewModel.isSubmitting,
            onPressed: _submit,
          ),
          children: [
            FadeSlideIn(child: AccountCard(account: _viewModel.preview, isBalanceVisible: true)),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Número da conta',
              placeholder: 'Ex.: 7',
              controller: _accountController,
              errorText: _viewModel.accountError,
              hintText: _agencyHint,
              enabled: !_viewModel.isSubmitting,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              textInputAction: TextInputAction.next,
              onChanged: _viewModel.updateAccountNumber,
              onSubmitted: (_) => _holderFocusNode.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Nome do titular',
              placeholder: 'Ex.: Maria Souza',
              controller: _holderController,
              focusNode: _holderFocusNode,
              errorText: _viewModel.holderError,
              enabled: !_viewModel.isSubmitting,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              onChanged: _viewModel.updateHolderName,
              onSubmitted: (_) => _ownerFocusNode.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Usuário dono',
              placeholder: 'Usuário que fará login',
              controller: _ownerController,
              focusNode: _ownerFocusNode,
              errorText: _viewModel.ownerError,
              hintText: 'Precisa ser um correntista já cadastrado.',
              enabled: !_viewModel.isSubmitting,
              inputFormatters: usernameInputFormatters,
              textInputAction: TextInputAction.next,
              onChanged: _viewModel.updateOwner,
              onSubmitted: (_) => _balanceFocusNode.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Saldo inicial',
              placeholder: formatCurrency(0),
              controller: _balanceController,
              focusNode: _balanceFocusNode,
              enabled: !_viewModel.isSubmitting,
              keyboardType: TextInputType.number,
              inputFormatters: const [CurrencyInputFormatter()],
              textInputAction: TextInputAction.done,
              onChanged: (text) =>
                  _viewModel.updateInitialBalance(CurrencyInputFormatter.centsFrom(text)),
              onSubmitted: (_) => _submit(),
            ),
            if (formError != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppNotice(message: formError, tone: AppNoticeTone.danger),
            ],
          ],
        );
      },
    );
  }
}
