import 'package:flutter/material.dart';
import '../core/localization/localized_text.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../data/models/order_model.dart';
import '../data/repositories/app_repository.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/services/auth_service.dart';
import '../features/orders/services/order_service.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/nafath_verification_screen.dart';
import '../features/catalog/screens/home_catalog_screen.dart';
import '../features/orders/screens/orders_list_screen.dart';
import '../features/wallet/screens/wallet_addresses_screen.dart';
import '../features/support/screens/support_warranty_screen.dart';

enum AppAuthStep {
  login,
  register,
  nafathVerification,
  authenticatedHome
}

class RootAppFlowShell extends StatefulWidget {
  final ThemeMode themeMode;
  final String languageCode;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;

  const RootAppFlowShell({
    super.key,
    required this.themeMode,
    required this.languageCode,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  @override
  State<RootAppFlowShell> createState() => _RootAppFlowShellState();
}

class _RootAppFlowShellState extends State<RootAppFlowShell> {
  AppAuthStep _currentStep = AppAuthStep.login;
  int _currentTab = 0;

  String? _orderLoadError;

  Future<void> _enterHome() async {
    if (AuthService.instance.authenticated) {
      AppRepository.sampleOrders = [];
      try {
        final orders = await OrderService().load();
        if (!mounted) return;
        AppRepository.sampleOrders = orders;
        _orderLoadError = null;
      } catch (_) {
        _orderLoadError = 'تعذر تحميل الطلبات. أعد المحاولة.';
      }
    }
    if (!AuthService.instance.authenticated) AppRepository.sampleOrders = AppRepository.createDemoOrders();
    if (mounted) setState(() => _currentStep = AppAuthStep.authenticatedHome);
  }

  void _addNewOrder(OrderModel order) {
    setState(() {
      AppRepository.sampleOrders.insert(0, order);
      _currentTab = 1; // Switch to Orders tab
    });
  }

  void _updateOrder(OrderModel updatedOrder) {
    setState(() {
      final index = AppRepository.sampleOrders.indexWhere((o) => o.id == updatedOrder.id);
      if (index != -1) {
        AppRepository.sampleOrders[index] = updatedOrder;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final lang = widget.languageCode;

    switch (_currentStep) {
      case AppAuthStep.login:
        return Scaffold(
          appBar: _buildTopControlBar(isDark, lang),
          body: LoginScreen(
            onProceedToNafath: () {
              _enterHome();
            },
            onNavigateToRegister: () {
              setState(() => _currentStep = AppAuthStep.register);
            },
          ),
        );

      case AppAuthStep.register:
        return Scaffold(
          appBar: _buildTopControlBar(isDark, lang),
          body: RegisterScreen(
            onProceedToNafath: () {
              _enterHome();
            },
            onNavigateToLogin: () {
              setState(() => _currentStep = AppAuthStep.login);
            },
          ),
        );

      case AppAuthStep.nafathVerification:
        return Scaffold(
          appBar: _buildTopControlBar(isDark, lang),
          body: NafathVerificationScreen(
            onVerificationSuccess: () {
              _enterHome();
            },
            onCancel: () {
              setState(() => _currentStep = AppAuthStep.login);
            },
          ),
        );

      case AppAuthStep.authenticatedHome:
        final user = AppRepository.currentUser;
        final List<Widget> pages = [
          HomeCatalogScreen(onOrderCreated: _addNewOrder),
          OrdersListScreen(
            orders: AppRepository.sampleOrders,
            onOrderUpdated: _updateOrder,
          ),
          const WalletAddressesScreen(),
          const SupportWarrantyScreen(),
        ];

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                if (_orderLoadError != null) Row(children: [
                  Expanded(child: AppText(_orderLoadError!)),
                  TextButton(onPressed: _enterHome, child: const AppText('إعادة المحاولة')),
                ]),
                if (!AuthService.instance.authenticated) const Padding(
                  padding: EdgeInsets.all(8), child: AppText('نسخة تجريبية • البيانات توضيحية')),
                // Top Header Profile & Mode Controls Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            radius: 14,
                            child: const Icon(Icons.person, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                AuthService.instance.authenticated ? 'SALLIH' : (user?.fullName ?? 'عبدالله الشمري'),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              AppText(
                                AuthService.instance.authenticated ? 'SALLIH' : translate(context, 'نسخة تجريبية • البيانات توضيحية'),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          )),
                        ],
                      )),

                      Row(
                        children: [
                          IconButton(tooltip: translate(context, 'تسجيل الخروج'),
                            onPressed: () {
                              AuthService.instance.signOut();
                              AppRepository.sampleOrders = [];
                              setState(() { _currentStep = AppAuthStep.login; _currentTab = 0; _orderLoadError = null; });
                            }, icon: const Icon(Icons.logout, size: 18)),
                          // Display controls
                          const SizedBox(width: 8),

                          // Theme Toggle Button
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            icon: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: widget.onToggleTheme,
                          ),

                          // Language Switcher Button
                          InkWell(
                            onTap: widget.onToggleLanguage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.withAlpha(80)),
                              ),
                              child: AppText(
                                lang == 'ar' ? 'EN' : 'عربي',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: pages[_currentTab]),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: (index) => setState(() => _currentTab = index),
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: isDark ? Colors.white54 : Colors.grey[600],
            selectedFontSize: 11,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.grid_view_rounded, size: 20),
                label: AppStrings.getString('home_tab', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.assignment_rounded, size: 20),
                label: AppStrings.getString('orders_tab', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.account_balance_wallet_rounded, size: 20),
                label: AppStrings.getString('wallet_tab', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.support_agent_rounded, size: 20),
                label: AppStrings.getString('support_tab', lang),
              ),
            ],
          ),
        );
    }
  }

  AppBar _buildTopControlBar(bool isDark, String lang) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
          onPressed: widget.onToggleTheme,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 12),
          child: TextButton(
            onPressed: widget.onToggleLanguage,
            child: AppText(
              lang == 'ar' ? 'English' : 'عربي',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
