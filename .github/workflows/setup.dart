import 'package:flutter/material.dart';
import '../services/config_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class SetupApp extends StatelessWidget {
  const SetupApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANIMA POS — Setup',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const SetupScreen(),
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final urlCtrl = TextEditingController();
  final keyCtrl = TextEditingController();
  String currency = 'BDT';
  String theme = 'light';
  bool busy = false;
  String? error;

  Future<void> _save() async {
    setState(() { busy = true; error = null; });
    try {
      final cfg = AppConfig(supabaseUrl: urlCtrl.text.trim(), supabaseAnonKey: keyCtrl.text.trim(), currency: currency, theme: theme);
      await ConfigService.save(cfg);
      await Supabase.initialize(url: cfg.supabaseUrl, anonKey: cfg.supabaseAnonKey, debug: false);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AnimaPOS(themeMode: cfg.theme == 'dark' ? ThemeMode.dark : ThemeMode.light)));
    } catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      setState(() { busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database & Theme Setup')),
      body: Center(
        child: SizedBox(
          width: 520,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('ANIMA POS — First-time Setup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'Supabase URL (https://...supabase.co)')),
                const SizedBox(height: 8),
                TextField(controller: keyCtrl, decoration: const InputDecoration(labelText: 'Supabase Anon Key'), obscureText: true),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: currency,
                  onChanged: (v) => setState(() => currency = v ?? 'BDT'),
                  items: const [
                    DropdownMenuItem(value: 'BDT', child: Text('BDT (৳)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD ($)')),
                  ],
                  decoration: const InputDecoration(labelText: 'Currency'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: theme,
                  onChanged: (v) => setState(() => theme = v ?? 'light'),
                  items: const [
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  ],
                  decoration: const InputDecoration(labelText: 'Theme'),
                ),
                const SizedBox(height: 12),
                if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: busy ? null : _save, icon: const Icon(Icons.save), label: const Text('Save & Continue')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
