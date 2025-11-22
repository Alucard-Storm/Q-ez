import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/cache_repository.dart';
import '../repositories/hive_cache_repository.dart';

/// Provider for the cache repository
final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return HiveCacheRepository();
});
