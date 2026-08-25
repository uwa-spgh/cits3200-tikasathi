import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/providers/language_provider.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';

import 'home_repository.dart';

part 'home_status_groups_provider.g.dart';

@Riverpod(keepAlive: true)
class HomeStatusGroups extends _$HomeStatusGroups {
  @override
  Future<List<HomeStatusGroup>> build() async {
    final isNp = ref.watch(languageProvider) == 'np';
    final repository = HomeRepository(ref.watch(appDatabaseProvider));
    return repository.loadHomeStatusGroups(isNp: isNp);
  }
}
