import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'setup.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  num cashSales = 0, creditSales = 0, totalDue = 0, totalAdvance = 0;

  @override
  void initState() {
    super.initState();
    _loadKpis();
  }

  Future<void> _loadKpis() async {
    try {
      final sb = Supabase.instance.client;
      // In real app: use active branch from session storage
      final br = await sb.from('branches').select('id').eq('is_active', true).limit(1);
      if (br.isEmpty) return;
      final k = await sb.rpc('daily_kpis', params: {'p_branch': br.first['id']});
      setState(() {
        cashSales = (k['cash_sales'] ?? 0);
        creditSales = (k['credit_sales'] ?? 0);
        totalDue = (k['total_due'] ?? 0);
        totalAdvance = (k['total_advance'] ?? 0);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), actions: [
        IconButton(onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetupScreen())); }, icon: const Icon(Icons.settings)),
        IconButton(onPressed: () async { await Supabase.instance.client.auth.signOut(); }, icon: const Icon(Icons.logout))
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(spacing: 12, runSpacing: 12, children: [
          _kpi('Cash Sales (Today)', cashSales),
          _kpi('Credit Sales (Today)', creditSales),
          _kpi('Total Due', totalDue),
          _kpi('Total Advance', totalAdvance),
        ]),
      ),
    );
  }

  Widget _kpi(String title, num value) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14)), const SizedBox(height: 8),
      Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    ])),
  );
}
