import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_message.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/ui/core/widgets/app_status_bar.dart';
import 'package:iceibank/ui/core/widgets/fade_slide_in.dart';
import 'package:iceibank/ui/home/view_models/home_view_model.dart';
import 'package:iceibank/ui/home/widgets/account_card_carousel.dart';
import 'package:iceibank/ui/home/widgets/agency_distribution.dart';
import 'package:iceibank/ui/home/widgets/balance_overview.dart';
import 'package:iceibank/ui/home/widgets/bank_accounts_list.dart';
import 'package:iceibank/ui/home/widgets/home_header.dart';
import 'package:iceibank/ui/home/widgets/home_states.dart';
import 'package:iceibank/ui/home/widgets/manager_overview.dart';
import 'package:iceibank/ui/home/widgets/quick_actions.dart';
import 'package:iceibank/ui/operations/widgets/operation_screen.dart';
import 'package:iceibank/ui/transfers/widgets/transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.authRepository, required this.accountRepository});

  final AuthRepository authRepository;
  final AccountRepository accountRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel = HomeViewModel(
    authRepository: widget.authRepository,
    accountRepository: widget.accountRepository,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_viewModel.load());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Deseja sair da sua conta?'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
      ),
    );

    if (shouldSignOut ?? false) unawaited(_viewModel.signOut());
  }

  void _showComingSoon(String operation) {
    unawaited(
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(operation),
          content: const Text('Essa operação chega na próxima etapa do app.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOperation(OperationType type) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => OperationScreen(
          type: type,
          accounts: _viewModel.accounts,
          accountRepository: widget.accountRepository,
        ),
      ),
    );
    if (mounted) unawaited(_viewModel.load());
  }

  Future<void> _openTransfer() async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => TransferScreen(
          accounts: _viewModel.accounts,
          accountRepository: widget.accountRepository,
        ),
      ),
    );
    if (mounted) unawaited(_viewModel.load());
  }

  List<QuickAction> get _actions {
    QuickAction action(String label, IconData icon) {
      return QuickAction(label: label, icon: icon, onPressed: () => _showComingSoon(label));
    }

    return [
      if (_viewModel.isManager) ...[
        action('Novo correntista', CupertinoIcons.person_badge_plus),
        action('Abrir conta', CupertinoIcons.plus_rectangle_on_rectangle),
      ],
      QuickAction(
        label: OperationType.deposit.title,
        icon: CupertinoIcons.arrow_down_to_line,
        onPressed: () => _openOperation(OperationType.deposit),
      ),
      QuickAction(
        label: OperationType.withdraw.title,
        icon: CupertinoIcons.arrow_up_to_line,
        onPressed: () => _openOperation(OperationType.withdraw),
      ),
      QuickAction(
        label: 'Transferir',
        icon: CupertinoIcons.arrow_right_arrow_left,
        onPressed: _openTransfer,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppStatusBar(
      child: CupertinoPageScaffold(
        backgroundColor: context.resolve(AppColors.background),
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                CupertinoSliverRefreshControl(onRefresh: _viewModel.load),
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xxl,
                  ),
                  sliver: SliverList.list(children: _sections()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sections() {
    final viewModel = _viewModel;
    final sections = <Widget>[
      _padded(
        HomeHeader(
          initials: viewModel.initials,
          greetingName: viewModel.greetingName,
          subtitle: viewModel.isManager ? 'Painel do gerente' : 'Bem-vindo ao seu ICEIBank',
          onSignOut: _confirmSignOut,
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
    ];

    if (!viewModel.hasLoaded) {
      final error = viewModel.errorMessage;
      sections.add(
        _padded(
          error == null
              ? const HomeSkeleton()
              : AppMessage(
                  icon: CupertinoIcons.wifi_exclamationmark,
                  title: 'Não foi possível carregar suas contas',
                  message: error,
                  actionLabel: 'Tentar novamente',
                  onAction: viewModel.load,
                ),
        ),
      );
      return sections;
    }

    final body = viewModel.isManager ? _managerSections() : _customerSections();
    for (var index = 0; index < body.length; index++) {
      sections.add(
        FadeSlideIn(
          delay: Duration(milliseconds: 70 * index),
          child: body[index],
        ),
      );
    }
    return sections;
  }

  List<Widget> _customerSections() {
    final viewModel = _viewModel;
    final accounts = viewModel.accounts;

    return [
      _padded(
        BalanceOverview(
          label: accounts.length > 1 ? 'Saldo total' : 'Saldo disponível',
          amount: viewModel.totalBalance,
          caption: _customerCaption(accounts),
          isVisible: viewModel.isBalanceVisible,
          onToggleVisibility: viewModel.toggleBalanceVisibility,
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      if (accounts.isEmpty)
        _padded(
          const AppMessage(
            icon: CupertinoIcons.creditcard,
            title: 'Nenhuma conta no seu nome',
            message: 'Procure o gerente para abrir a sua conta.',
          ),
        )
      else
        AccountCardCarousel(accounts: accounts, isBalanceVisible: viewModel.isBalanceVisible),
      ..._sharedSections(),
    ];
  }

  List<Widget> _managerSections() {
    final viewModel = _viewModel;
    final accounts = viewModel.accounts;

    return [
      _padded(
        ManagerOverview(
          totalBalance: viewModel.totalBalance,
          accountCount: accounts.length,
          holderCount: viewModel.holderCount,
          availableAgencyCount: viewModel.availableAgencyCount,
          isBalanceVisible: viewModel.isBalanceVisible,
          onToggleVisibility: viewModel.toggleBalanceVisibility,
        ),
      ),
      ..._sharedSections(),
      const SizedBox(height: AppSpacing.xxl),
      _padded(
        AgencyDistribution(
          summaries: viewModel.agencySummaries,
          isBalanceVisible: viewModel.isBalanceVisible,
        ),
      ),
      const SizedBox(height: AppSpacing.xxl),
      _padded(_SectionTitle(title: 'Contas do banco', trailing: '${accounts.length}')),
      const SizedBox(height: AppSpacing.md),
      _padded(
        accounts.isEmpty
            ? AppMessage(
                icon: CupertinoIcons.person_badge_plus,
                title: 'Nenhuma conta aberta ainda',
                message: 'Cadastre um correntista e abra a primeira conta do banco.',
                actionLabel: 'Cadastrar correntista',
                onAction: () => _showComingSoon('Novo correntista'),
              )
            : BankAccountsList(accounts: accounts, isBalanceVisible: viewModel.isBalanceVisible),
      ),
    ];
  }

  List<Widget> _sharedSections() {
    final viewModel = _viewModel;
    final unavailable = viewModel.unavailableAgencies;
    final refreshError = viewModel.errorMessage;

    return [
      if (unavailable.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        _padded(
          AppNotice(
            tone: AppNoticeTone.danger,
            message:
                'Não foi possível falar com a ${unavailable.map((id) => 'Agência $id').join(', ')}. '
                'As contas de lá não entram nesta soma até a agência voltar.',
          ),
        ),
      ],
      if (refreshError != null) ...[
        const SizedBox(height: AppSpacing.xl),
        _padded(AppNotice(tone: AppNoticeTone.danger, message: refreshError)),
      ],
      const SizedBox(height: AppSpacing.xxl),
      _padded(const _SectionTitle(title: 'O que você quer fazer')),
      const SizedBox(height: AppSpacing.lg),
      _padded(QuickActions(actions: _actions)),
    ];
  }

  String _customerCaption(List<Account> accounts) {
    if (accounts.isEmpty) return 'Nenhuma conta no seu nome';
    if (accounts.length == 1) {
      return 'Conta ${accounts.first.id} · Agência ${accounts.first.agencyId}';
    }
    return 'Somando suas ${accounts.length} contas';
  }

  Widget _padded(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final count = trailing;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.headline.copyWith(color: context.resolve(AppColors.text)),
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: context.resolve(AppColors.fill),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              count,
              style: AppTypography.caption.copyWith(
                color: context.resolve(AppColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }
}
