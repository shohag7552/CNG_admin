import 'package:appwrite_boilerplate/app/helper/mock_admin_store.dart';
import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/modules/audit/domain/repository/audit_repo_interface.dart';

class AuditRepository implements AuditRepoInterface {
  final MockAdminStore store;
  final Duration tick;

  AuditRepository({required this.store, this.tick = const Duration(milliseconds: 500)});

  @override
  Future<PageResult<AuditLogModel>> getLogs({
    AuditAction? action,
    required int offset,
    required int limit,
  }) async {
    await Future<void>.delayed(tick);
    final all = store.audit.where((a) => action == null || a.action == action).toList();
    return PageResult(all.skip(offset).take(limit).toList(), all.length);
  }
}
