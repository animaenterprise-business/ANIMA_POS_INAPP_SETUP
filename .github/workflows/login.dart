import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? selectedBranchId;
  List<Map<String, dynamic>> branches = [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final res = await Supabase.instance.client.from('branches').select('id,name,code').eq('is_active', true);
      setState(() => branches = List<Map<String, dynamic>>.from(res));
    } catch (_) {}
  }

  Future<void> _login() async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('ANIMA POS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedBranchId,
                  items: branches.map((b) => DropdownMenuItem(value: b['id'], child: Text('${b['code']} — ${b['name']}'))).toList(),
                  onChanged: (v) => setState(() => selectedBranchId = v),
                  decoration: const InputDecoration(labelText: 'Branch'),
                ),
                const SizedBox(height: 8),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _login, child: const Text('Login')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
