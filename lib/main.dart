import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'data/models/order_model.dart';
import 'data/repositories/app_repository.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/nafath_verification_screen.dart';
import 'features/catalog/screens/home_catalog_screen.dart';
import 'features/orders/screens/orders_list_screen.dart';
import 'features/wallet/screens/wallet_addresses_screen.dart';
import 'features/support/screens/support_warranty_screen.dart';

void main() {
  runApp(const SallihCustomerApp());
}

class SallihCustomerApp extends StatefulWidget {
  const SallihCustomerApp({super.key});

  @override
  State<SallihCustomerApp> createState() => _SallihCustomerAppState();
}

class _SallihCustomerAppState extends State<SallihCustomerApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'ar';

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _languageCode = _languageCode == 'ar' ? 'en' : 'ar';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = _languageCode == 'ar';

    return MaterialApp(
      title: 'صلّح | SALLIH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      builder: (context, child) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: RootAppFlowShell(
        themeMode: _themeMode,
        languageCode: _languageCode,
        onToggleTheme: _toggleTheme,
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}

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
              setState(() => _currentStep = AppAuthStep.nafathVerification);
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
              setState(() => _currentStep = AppAuthStep.nafathVerification);
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
              setState(() => _currentStep = AppAuthStep.authenticatedHome);
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
                // Top Header Profile & Mode Controls Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            radius: 14,
                            child: const Icon(Icons.person, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'عبدالله الشمري',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                '${lang == 'ar' ? 'الهوية' : 'ID'}: ${user?.nationalId ?? '1098765432'}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          // Nafath Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.nafathGreen.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.nafathGreen.withAlpha(60)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified, size: 12, color: AppTheme.nafathGreen),
                                const SizedBox(width: 3),
                                Text(
                                  AppStrings.getString('nafath_verified', lang),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppTheme.nafathGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

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
                              child: Text(
                                lang == 'ar' ? 'EN' : 'عربي',
                                style: TextStyle(
                                  fontSize: 10,
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
            child: Text(
              lang == 'ar' ? 'English' : 'عربي',
              style: TextStyle(
                fontSize: 12,
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
