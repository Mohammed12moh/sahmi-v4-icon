import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config.dart';
import '../../core/password_strength.dart';
import '../../core/support.dart';
import '../../core/theme.dart';
import '../auth/auth_repository.dart';
import '../market/market_providers.dart';

/// معلومات الحساب / Account info (الحقول المسموح تعديلها فقط)
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _phone, _district, _address;
  String? _city;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider).valueOrNull;
    _name = TextEditingController(text: (p?['full_name'] as String?) ?? '');
    _phone = TextEditingController(text: (p?['phone'] as String?) ?? '+964');
    _district = TextEditingController(text: (p?['district'] as String?) ?? '');
    _address = TextEditingController(text: (p?['address'] as String?) ?? '');
    final c = p?['city'] as String?;
    _city = iraqGovernorates.contains(c) ? c : null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final db = ref.read(supabaseProvider);
    final uid = db.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await db.from('profiles').update({
        'full_name': _name.text.trim(), 'phone': _phone.text.replaceAll(' ', ''),
        'city': _city, 'district': _district.text.trim(), 'address': _address.text.trim(),
      }).eq('id', uid);
      messenger.showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('تعذّر الحفظ، حاول مرة أخرى')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _district.dispose(); _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(profileProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('معلومات الحساب')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          ListTile(
            tileColor: C.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('البريد'),
            subtitle: Text(ref.read(supabaseProvider).auth.currentUser?.email ?? '-', textDirection: TextDirection.ltr),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: C.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('اسم المستخدم'),
            subtitle: Text('@${p?['username'] ?? ''}', textDirection: TextDirection.ltr),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              validator: (v) => (v ?? '').trim().isEmpty ? 'مطلوب' : null),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr,
            decoration: const InputDecoration(labelText: 'رقم الهاتف'),
            validator: (v) => RegExp(r'^\+9647[3-9]\d{8}$').hasMatch((v ?? '').replaceAll(' ', '')) ? null : 'مثال: +9647701234567',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _city,
            decoration: const InputDecoration(labelText: 'المحافظة'),
            items: [for (final g in iraqGovernorates) DropdownMenuItem(value: g, child: Text(g))],
            onChanged: (v) => _city = v,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _district, decoration: const InputDecoration(labelText: 'المنطقة / الحي')),
          const SizedBox(height: 12),
          TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'العنوان')),
          const SizedBox(height: 20),
          GlowButton('حفظ', loading: _loading, onPressed: _save),
        ]),
      ),
    );
  }
}

/// الأمان / Security
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});
  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _form = GlobalKey<FormState>();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _change() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(supabaseProvider).auth.updateUser(UserAttributes(password: _pass.text));
      _pass.clear();
      messenger.showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور')));
    } on AuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('تعذّر الاتصال')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _pass.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = passwordStrength(_pass.text);
    return Scaffold(
      appBar: AppBar(title: const Text('الأمان')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('تغيير كلمة المرور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pass, obscureText: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: 'كلمة المرور الجديدة', helperText: _pass.text.isEmpty ? null : 'القوة: ${pwLabels[s]}'),
            validator: (v) => (v ?? '').length >= 8 ? null : '8 أحرف على الأقل',
          ),
          const SizedBox(height: 12),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
            validator: (v) => v == _pass.text ? null : 'غير متطابقة',
          ),
          const SizedBox(height: 16),
          GlowButton('تغيير', loading: _loading, onPressed: _change),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(supabaseProvider).auth.signOut(scope: SignOutScope.global);
              } catch (_) {
                messenger.showSnackBar(const SnackBar(content: Text('تعذّر تسجيل الخروج')));
              }
            },
            icon: const Icon(Icons.devices),
            label: const Text('تسجيل الخروج من كل الأجهزة'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ]),
      ),
    );
  }
}

/// المساعدة / Help
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  static const _faq = [
    ('هل الأموال حقيقية؟', 'لا. سهمي نسخة تجريبية: الرصيد والأسعار والمكافآت كلها افتراضية لأغراض التعلّم.'),
    ('كيف تُحسب الإشارات؟', 'تجمع RSI وMA وMACD والحجم وبولينجر ومعنويات الأخبار بأوزان محددة، وتعطي درجة من 0 إلى 100. هي تعليمية وليست نصيحة استثمارية.'),
    ('كيف أرتقي بالمستوى؟', 'اجمع نقاط XP من الصفقات والحضور اليومي والتحديات والدعوات والشارات.'),
    ('كيف أدعو أصدقائي؟', 'من شاشة الدعوة انسخ رمزك أو شاركه، ويحصلون عليه عند التسجيل.'),
    ('نسيت كلمة المرور؟', 'تواصل مع الدعم عبر تلغرام وسنساعدك.'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('المساعدة')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          for (final q in _faq)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(14)),
              child: ExpansionTile(
                shape: const Border(), collapsedShape: const Border(),
                title: Text(q.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(q.$2, style: const TextStyle(color: Colors.white70, height: 1.6))],
              ),
            ),
          const SizedBox(height: 12),
          const SupportButton(topic: 'المساعدة'),
          const SizedBox(height: 8),
          const Center(child: Text('@${AppConfig.telegramHandle}', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white54))),
        ]),
      );
}

/// عن التطبيق / About
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('عن التطبيق')),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const Icon(Icons.show_chart_rounded, size: 72, color: C.gold),
          const SizedBox(height: 12),
          const Center(child: Text('سهمي', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: C.gold))),
          const Center(child: Text('الإصدار 0.4.0 (تجريبي)', style: TextStyle(color: Colors.white54))),
          const SizedBox(height: 20),
          const Text(
            'سهمي تطبيق تعليمي لمحاكاة التداول. جميع الأسعار والأخبار والأرصدة والمكافآت افتراضية، '
            'ولا يُعدّ المحتوى نصيحة استثمارية ولا يتضمن أي معاملات مالية حقيقية.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, height: 1.8),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => showLicensePage(context: context, applicationName: 'سهمي'),
            child: const Text('التراخيص'),
          ),
        ]),
      );
}
