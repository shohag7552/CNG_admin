import 'package:appwrite_boilerplate/app/controllers/paged_list_controller.dart';
import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/modules/audit/domain/repository/audit_repo_interface.dart';

class AuditController extends PagedListController<AuditLogModel> {
  final AuditRepoInterface auditRepoInterface;

  AuditController({required this.auditRepoInterface});

  AuditAction? _action;
  AuditAction? get action => _action;

  @override
  Future<PageResult<AuditLogModel>> fetchPage(int offset, int limit) =>
      auditRepoInterface.getLogs(action: _action, offset: offset, limit: limit);

  void setAction(AuditAction? a) {
    _action = a;
    load();
  }
}
