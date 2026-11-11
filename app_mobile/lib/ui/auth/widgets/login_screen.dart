import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/ui/auth/view_models/login_view_model.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/core/widgets/app_logo.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/ui/core/widgets/app_status_bar.dart';
import 'package:iceibank/ui/core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(authRepository: widget.authRepository);
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await _viewModel.submit(username: _usernameController.text, password: _passwordController.text);

    if (_viewModel.formError == null && _viewModel.usernameError == null) {
      TextInput.finishAutofillContext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStatusBar(
      child: CupertinoPageScaffold(
        backgroundColor: context.resolve(AppColors.surface),
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) => _LoginForm(
                        viewModel: _viewModel,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        passwordFocusNode: _passwordFocusNode,
                        onSubmit: _submit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.viewModel,
    required this.usernameController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.onSubmit,
  });

  final LoginViewModel viewModel;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final formError = viewModel.formError;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          const Center(child: AppLogo(markSize: 36)),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Acessar sua conta',
            style: AppTypography.title1.copyWith(color: context.resolve(AppColors.text)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Entre com seu usuário e senha.',
            style: AppTypography.subheadline.copyWith(
              color: context.resolve(AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppTextField(
            label: 'Usuário',
            placeholder: 'Seu nome de usuário',
            controller: usernameController,
            errorText: viewModel.usernameError,
            enabled: !viewModel.isSubmitting,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            onChanged: (_) => viewModel.clearUsernameError(),
            onSubmitted: (_) => passwordFocusNode.requestFocus(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Senha',
            placeholder: 'Sua senha',
            controller: passwordController,
            focusNode: passwordFocusNode,
            errorText: viewModel.passwordError,
            enabled: !viewModel.isSubmitting,
            isPassword: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onChanged: (_) => viewModel.clearPasswordError(),
            onSubmitted: (_) => onSubmit(),
          ),
          if (formError != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppNotice(message: formError, tone: AppNoticeTone.danger),
          ],
          const Spacer(),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Entrar', isLoading: viewModel.isSubmitting, onPressed: onSubmit),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Primeiro acesso? Use admin e a senha admin1234.',
            textAlign: TextAlign.center,
            style: AppTypography.footnote.copyWith(color: context.resolve(AppColors.textTertiary)),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
