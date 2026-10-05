import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_repository.dart';

class GamificationRepository {
  final SupabaseClient _db;
  GamificationRepository(this._db);

  Future<({int streak, int xp, bool already})> checkin() async {
    final r = Map<String, dynamic>.from(await _db.rpc('daily_checkin') as Map);
    return (streak: (r['streak'] as num).toInt(), xp: (r['xp'] as num).toInt(), already: r['already'] == true);
  }

  Future<int> claim(String key) async {
    final r = Map<String, dynamic>.from(await _db.rpc('claim_challenge', params: {'p_key': key}) as Map);
    return (r['xp'] as num).toInt();
  }
}

final gamificationRepoProvider = Provider((ref) => GamificationRepository(ref.watch(supabaseProvider)));

final badgesProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  final rows = await ref.watch(supabaseProvider).from('user_badges').select('badge');
  return {for (final r in rows) r['badge'] as String};
});

final challengesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final rows = await ref.watch(supabaseProvider).rpc('my_challenges');
  return List<Map<String, dynamic>>.from(rows as List);
});
