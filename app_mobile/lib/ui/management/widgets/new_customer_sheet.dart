import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/data/repositories/user_repository.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/widgets/animated_check.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/ui/core/widgets/app_text_field.dart';
import 'package:iceibank/ui/core/widgets/fade_slide_in.dart';
import 'package:iceibank/ui/management/view_models/new_customer_view_model.dart';
import 'package:iceibank/ui/management/widgets/management_sheet.dart';
import 'package:iceibank/utils/text_formatters.dart';

Future<String?> showNewCustomerSheet(BuildContext context, {required UserRepository repository}) {
  return showCupertinoSheet<String>(
    context: context,
    scrollableBuilder: (context, scrollController) =>
        NewCustomerSheet(repository: repository, scrollController: scrollController),
  );
}

class NewCustomerSheet extends StatefulWidget {
  const NewCustomerSheet({super.key, required this.repository, required this.scrollController});

  final UserRepository repository;
  final ScrollController scrollController;

  @override
  State<NewCustomerSheet> createState() => _NewCustomerSheetState();
}

class _NewCustomerSheetState extends State<NewCustomerSheet> {
  late final NewCustomerViewModel _viewModel = NewCustomerViewModel(
    userRepository: widget.repository,
  );

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _viewModel.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await _viewModel.submit(username: _usernameController.text, password: _passwordController.text);

    if (_viewModel.createdUsername != null) {
      await HapticFeedback.mediumImpact();
    } else if (_viewModel.formError != null || _viewModel.usernameError != null) {
      await HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final createdUsername = _viewModel.createdUsername;

        if (createdUsername != null) {
          return ManagementSheet(
            title: 'Novo correntista',
            scrollController: widget.scrollController,
            canCancel: false,
            footer: Column(
              children: [
                AppButton(
                  label: 'Abrir conta para @$createdUsername',
                  onPressed: () => Navigator.of(context).pop(createdUsername),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Concluir'),
                ),
              ],
            ),
            children: [
              const SizedBox(height: AppSpacing.xxl),
              const Center(child: AnimatedCheck()),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                child: SheetSuccess(
                  title: 'Correntista cadastrado',
                  message:
                      '@$createdUsername já pode entrar no app. '
                      'Agora abra uma conta bancária para essa pessoa.',
                ),
              ),
            ],
          );
        }

        final formError = _viewModel.formError;

        return ManagementSheet(
          title: 'Novo correntista',
          showTitle: false,
          scrollController: widget.scrollController,
          footer: AppButton(
            label: 'Cadastrar correntista',
            isLoading: _viewModel.isSubmitting,
            onPressed: _submit,
          ),
          children: [
            const SheetIntro(
              icon: CupertinoIcons.person_badge_plus,
              title: 'Novo correntista',
              message: 'Cadastre o acesso de um cliente. Depois abra a conta bancária dele.',
            ),
            const SizedBox(height: AppSpacing.xxl),
            Column(
              children: [
                AppTextField(
                  label: 'Usuário',
                  placeholder: 'Ex.: ana',
                  controller: _usernameController,
                  errorText: _viewModel.usernameError,
                  hintText: 'É com esse nome que a pessoa vai entrar no app.',
                  enabled: !_viewModel.isSubmitting,
                  inputFormatters: usernameInputFormatters,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _viewModel.clearUsernameError(),
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Senha',
                  placeholder: 'Mínimo de 6 caracteres',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  errorText: _viewModel.passwordError,
                  enabled: !_viewModel.isSubmitting,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => _viewModel.clearPasswordError(),
                  onSubmitted: (_) => _submit(),
                ),
              ],
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
