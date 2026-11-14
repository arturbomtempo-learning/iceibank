import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/agency_repository.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/repositories/leadership_repository.dart';
import 'package:iceibank/data/repositories/sync_repository.dart';
import 'package:iceibank/data/repositories/user_repository.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
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
import 'package:iceibank/ui/home/widgets/agency_routing_tile.dart';
import 'package:iceibank/ui/home/widgets/balance_overview.dart';
import 'package:iceibank/ui/home/widgets/bank_accounts_list.dart';
import 'package:iceibank/ui/home/widgets/home_header.dart';
import 'package:iceibank/ui/home/widgets/home_states.dart';
import 'package:iceibank/ui/home/widgets/manager_overview.dart';
import 'package:iceibank/ui/home/widgets/quick_actions.dart';
import 'package:iceibank/ui/leadership/view_models/leadership_view_model.dart';
import 'package:iceibank/ui/leadership/widgets/leadership_panel.dart';
import 'package:iceibank/ui/management/widgets/new_account_sheet.dart';
import 'package:iceibank/ui/management/widgets/new_customer_sheet.dart';
import 'package:iceibank/ui/operations/widgets/operation_screen.dart';
import 'package:iceibank/ui/sync/widgets/pending_decision_sheet.dart';
import 'package:iceibank/ui/sync/widgets/pending_operations_section.dart';
import 'package:iceibank/ui/transfers/widgets/transfer_screen.dart';
import 'package:iceibank/utils/time.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authRepository,
    required this.accountRepository,
    required this.userRepository,
    required this.agencyRepository,
    required this.leadershipRepository,
    required this.syncRepository,
  });

  final AuthRepository authRepository;
  final AccountRepository accountRepository;
  final UserRepository userRepository;
  final AgencyRepository agencyRepository;
  final LeadershipRepository leadershipRepository;
  final SyncRepository syncRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel = HomeViewModel(
    authRepository: widget.authRepository,
    accountRepository: widget.accountRepository,
    agencyRepository: widget.agencyRepository,
    syncRepository: widget.syncRepository,
  );
  late final LeadershipViewModel _leadershipViewModel = LeadershipViewModel(
    leadershipRepository: widget.leadershipRepository,
  );
  late final AppLifecycleListener _lifecycleListener;
  SyncReport? _announcedReport;

  @override
  void initState() {
    super.initState();
    _announcedReport = _viewModel.lastSyncReport;
    _viewModel.addListener(_announceConflicts);
    unawaited(_viewModel.start());
    _leadershipViewModel.start();
    _lifecycleListener = AppLifecycleListener(
      onShow: () {
        _leadershipViewModel.start();
        _viewModel.resumeSync();
      },
      onHide: () {
        _leadershipViewModel.stop();
        _viewModel.pauseSync();
      },
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_announceConflicts);
    _lifecycleListener.dispose();
    _leadershipViewModel.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _announceConflicts() {
    final report = _viewModel.lastSyncReport;
    if (report == null || identical(report, _announcedReport)) return;
    _announcedReport = report;

    if (report.conflictCount + report.rejectedCount > 0) {
      unawaited(HapticFeedback.heavyImpact());
    } else if (report.appliedCount > 0) {
      unawaited(HapticFeedback.lightImpact());
    }
  }

  Future<void> _decide(PendingOperation operation) async {
    final decision = await showPendingDecisionSheet(context, operation: operation);
    switch (decision) {
      case PendingDecision.retry:
        unawaited(HapticFeedback.selectionClick());
        await _viewModel.retryOperation(operation);
      case PendingDecision.discard:
        unawaited(HapticFeedback.selectionClick());
        await _viewModel.discardOperation(operation);
      case null:
        return;
    }
  }

  Future<void> _confirmSignOut() async {
    final waiting = _viewModel.waitingCount;
    final shouldSignOut = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Deseja sair da sua conta?'),
        message: waiting == 0
            ? null
            : Text(
                waiting == 1
                    ? 'Você tem uma operação pendente. Ela continua guardada e é enviada '
                          'quando você entrar de novo.'
                    : 'Você tem $waiting operações pendentes. Elas continuam guardadas e são '
                          'enviadas quando você entrar de novo.',
              ),
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

  Future<void> _openNewCustomer() async {
    final createdUsername = await showNewCustomerSheet(context, repository: widget.userRepository);
    if (createdUsername != null && mounted) {
      await _openNewAccount(initialOwner: createdUsername);
    }
  }

  Future<void> _openNewAccount({String initialOwner = ''}) async {
    final created = await showNewAccountSheet(
      context,
      repository: widget.accountRepository,
      initialOwner: initialOwner,
    );
    if ((created ?? false) && mounted) unawaited(_viewModel.load());
  }

  Future<void> _openOperation(OperationType type) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => OperationScreen(
          type: type,
          username: _viewModel.username,
          accounts: _viewModel.accounts,
          accountRepository: widget.accountRepository,
          syncRepository: widget.syncRepository,
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
    return [
      if (_viewModel.isManager) ...[
        QuickAction(
          label: 'Novo correntista',
          icon: CupertinoIcons.person_badge_plus,
          onPressed: _openNewCustomer,
        ),
        QuickAction(
          label: 'Abrir conta',
          icon: CupertinoIcons.plus_rectangle_on_rectangle,
          onPressed: _openNewAccount,
        ),
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
          isProvisional: viewModel.waitingCount > 0,
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
      ..._agencyAccessSection(),
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
                onAction: _openNewCustomer,
              )
            : BankAccountsList(
                accounts: accounts,
                isBalanceVisible: viewModel.isBalanceVisible,
                pendingAccountIds: viewModel.accountsWithPending,
              ),
      ),
      ..._agencyAccessSection(),
    ];
  }

  List<Widget> _sharedSections() {
    final viewModel = _viewModel;
    final refreshError = viewModel.errorMessage;
    final availabilityNotice = _availabilityNotice();
    final operations = viewModel.pendingOperations;

    return [
      if (availabilityNotice != null) ...[
        const SizedBox(height: AppSpacing.xl),
        _padded(AppNotice(tone: AppNoticeTone.danger, message: availabilityNotice)),
      ],
      if (refreshError != null) ...[
        const SizedBox(height: AppSpacing.xl),
        _padded(AppNotice(tone: AppNoticeTone.danger, message: refreshError)),
      ],
      if (operations.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xxl),
        _padded(_SectionTitle(title: 'Operações pendentes', trailing: '${operations.length}')),
        const SizedBox(height: AppSpacing.md),
        _padded(
          PendingOperationsSection(
            operations: operations,
            isSyncing: viewModel.isSyncing,
            onDecide: _decide,
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.xxl),
      _padded(const _SectionTitle(title: 'O que você quer fazer')),
      const SizedBox(height: AppSpacing.lg),
      _padded(QuickActions(actions: _actions)),
      const SizedBox(height: AppSpacing.xxl),
      _padded(const _SectionTitle(title: 'Liderança das agências')),
      const SizedBox(height: AppSpacing.md),
      _padded(LeadershipPanel(viewModel: _leadershipViewModel)),
    ];
  }

  List<Widget> _agencyAccessSection() {
    return [
      const SizedBox(height: AppSpacing.xxl),
      _padded(const _SectionTitle(title: 'Acesso às agências')),
      const SizedBox(height: AppSpacing.md),
      _padded(
        AgencyRoutingTile(
          pinnedAgencyId: _viewModel.pinnedAgencyId,
          onSelected: _viewModel.selectAgency,
        ),
      ),
    ];
  }

  String? _availabilityNotice() {
    final viewModel = _viewModel;
    final unavailable = viewModel.unavailableAgencies;
    if (unavailable.isEmpty) return null;

    final lastSeen = switch (viewModel.cachedAt) {
      final cachedAt? => formatLastSeen(cachedAt),
      null => null,
    };

    if (viewModel.isOffline) {
      return 'Sem conexão com as agências. Você está vendo o último saldo conhecido'
          '${lastSeen == null ? '' : ', $lastSeen'}.';
    }

    final names = unavailable.map((id) => 'Agência $id').join(', ');
    if (!viewModel.hasStaleAccounts) {
      return 'Não foi possível falar com a $names. '
          'As contas de lá não entram nesta soma até a agência voltar.';
    }
    return 'Não foi possível falar com a $names. As contas de lá aparecem com o último '
        'saldo conhecido${lastSeen == null ? '' : ', $lastSeen'}.';
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
