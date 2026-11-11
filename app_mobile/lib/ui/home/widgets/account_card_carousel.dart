import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/home/widgets/account_card.dart';

class AccountCardCarousel extends StatefulWidget {
  const AccountCardCarousel({super.key, required this.accounts, required this.isBalanceVisible});

  final List<Account> accounts;
  final bool isBalanceVisible;

  @override
  State<AccountCardCarousel> createState() => _AccountCardCarouselState();
}

class _AccountCardCarouselState extends State<AccountCardCarousel> {
  static const double _viewportFraction = 0.88;
  static const double _gap = AppSpacing.md;

  final _controller = PageController(viewportFraction: _viewportFraction);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMany = widget.accounts.length > 1;

    return Column(
      children: [
        if (hasMany)
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth * _viewportFraction - _gap;

              return SizedBox(
                height: cardWidth / AccountCard.aspectRatio + AppSpacing.xl,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.accounts.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _gap / 2),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: AccountCard(
                        account: widget.accounts[index],
                        isBalanceVisible: widget.isBalanceVisible,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: AccountCard(
              account: widget.accounts.first,
              isBalanceVisible: widget.isBalanceVisible,
            ),
          ),
        SizedBox(height: hasMany ? AppSpacing.xs : AppSpacing.lg),
        if (hasMany)
          _PageIndicator(count: widget.accounts.length, current: _page)
        else
          Text(
            'Toque no cartão para ver os dados da conta',
            style: AppTypography.footnote.copyWith(color: context.resolve(AppColors.textTertiary)),
          ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cartão ${current + 1} de $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: index == current ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: context.resolve(
                  index == current ? AppColors.primary : AppColors.textTertiary,
                ),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
}
