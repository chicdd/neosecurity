import 'package:flutter/material.dart';
import 'package:neosecurity/Home.dart';
import 'functions.dart';

class Display extends StatefulWidget {
  const Display({super.key});

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 두 API를 병렬로 호출하여 시간 단축
    await Future.wait([
      getSmartSetting(),
      initializeData(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())) ,
      );
    }
    return const Home();
  }
}
