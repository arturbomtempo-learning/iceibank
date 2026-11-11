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
    _passwordFocusNode.addListener(_onPasswordFocusChanged);
  }

  @override
  void dispose() {
    _passwordFocusNode
      ..removeListener(_onPasswordFocusChanged)
      ..dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onPasswordFocusChanged() => setState(() {});

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await _viewModel.submit(username: _usernameController.text, password: _passwordController.text);

    if (_viewModel.formError == null && _viewModel.usernameError == null) {
      TextInput.finishAutofillContext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: CupertinoPageScaffold(
        backgroundColor: context.resolve(AppColors.ink),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: _LoginHeader(isPasswordFocused: _passwordFocusNode.hasFocus),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.isPasswordFocused});

  final bool isPasswordFocused;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.9, -1.1),
          radius: 1.3,
          colors: [Color(0x522FC187), Color(0x002FC187)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          topInset + AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: AppLogo(variant: AppLogoVariant.onInk, markSize: 30),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _MascotWindow(isCovered: isPasswordFocused),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                isPasswordFocused
                    ? 'Pode digitar. Não estamos olhando.'
                    : 'Que bom ver você por aqui de novo.',
                key: ValueKey(isPasswordFocused),
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: isPasswordFocused ? AppColors.accent : AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MascotWindow extends StatelessWidget {
  const _MascotWindow({required this.isCovered});

  final bool isCovered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      height: 136,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.resolve(AppColors.inkMuted).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: context.resolve(AppColors.inkMuted).withValues(alpha: 0.3)),
      ),
      child: AnimatedSlide(
        offset: isCovered ? const Offset(0, 0.08) : Offset.zero,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: isCovered ? 0.45 : 1,
          duration: const Duration(milliseconds: 300),
          child: Image.asset(
            'assets/images/mascot-head.webp',
            semanticLabel: 'Mascote do ICEIBank, um castor de moletom verde',
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final formError = viewModel.formError;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xxl,
        AppSpacing.screen,
        bottomInset + AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: context.resolve(AppColors.background),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl + 4)),
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Acessar sua conta',
              style: AppTypography.title.copyWith(color: context.resolve(AppColors.text)),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Entre com suas credenciais para acessar o ICEIBank.',
              style: AppTypography.callout.copyWith(color: context.resolve(AppColors.textMuted)),
            ),
            const SizedBox(height: AppSpacing.xl),
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
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onChanged: (_) => viewModel.clearPasswordError(),
              onSubmitted: (_) => onSubmit(),
            ),
            if (formError != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppNotice(message: formError, tone: AppNoticeTone.danger),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Entrar',
              loadingLabel: 'Entrando...',
              isLoading: viewModel.isSubmitting,
              onPressed: onSubmit,
            ),
            const SizedBox(height: AppSpacing.xl),
            const AppNotice(
              message:
                  'Primeiro acesso? Entre como admin com a senha admin1234 para cadastrar '
                  'correntistas e abrir contas.',
            ),
          ],
        ),
      ),
    );
  }
}
