import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qfnu_app/disclaimer/disclaimer_page.dart';
import 'package:qfnu_app/login/login_page.dart';
import 'package:qfnu_app/shared/settings_store.dart';

class DisclaimerGate extends StatefulWidget {
  const DisclaimerGate({super.key});

  @override
  State<DisclaimerGate> createState() => _DisclaimerGateState();
}

class _DisclaimerGateState extends State<DisclaimerGate> {
  bool _loading = true;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final accepted = await SettingsStore.getDisclaimerAccepted();
    if (!mounted) return;
    setState(() {
      _accepted = accepted;
      _loading = false;
    });
  }

  Future<void> _accept() async {
    await SettingsStore.setDisclaimerAccepted(true);
    if (!mounted) return;
    setState(() {
      _accepted = true;
    });
  }

  void _decline() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_accepted) {
      return const LoginPage();
    }

    return DisclaimerPage(
      showActions: true,
      onAccept: _accept,
      onDecline: _decline,
    );
  }
}
