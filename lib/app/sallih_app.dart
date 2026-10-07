import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import 'root_app_flow_shell.dart';
import '../features/location/services/address_store.dart';
import '../data/repositories/app_repository.dart';

class SallihCustomerApp extends StatefulWidget {
  const SallihCustomerApp({super.key});

  @override
  State<SallihCustomerApp> createState() => _SallihCustomerAppState();
}

class _SallihCustomerAppState extends State<SallihCustomerApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'ar';

  @override
  void initState() {
    super.initState();
    _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final savedAddresses = await AddressStore().load();
    AppRepository.addresses.removeWhere((entry) => entry.id.startsWith('local_'));
    AppRepository.addresses.addAll(savedAddresses);
    if (!mounted) return;
    setState(() {
      _languageCode = preferences.getString('language') == 'en' ? 'en' : 'ar';
      _themeMode = preferences.getBool('darkTheme') == true ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _savePreferences() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('language', _languageCode);
    await preferences.setBool('darkTheme', _themeMode == ThemeMode.dark);
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    _savePreferences();
  }

  void _toggleLanguage() {
    setState(() {
      _languageCode = _languageCode == 'ar' ? 'en' : 'ar';
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = _languageCode == 'ar';

    return MaterialApp(
      title: 'SALLIH',
      locale: Locale(_languageCode),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      builder: (context, child) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100), child: child!,
          )),
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
