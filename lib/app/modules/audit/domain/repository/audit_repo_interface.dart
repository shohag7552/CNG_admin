import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';

/// Read-only: entries are written by the server Function behind each action.
abstract class AuditRepoInterface {
  Future<PageResult<AuditLogModel>> getLogs({
    AuditAction? action,
    required int offset,
    required int limit,
  });
}
