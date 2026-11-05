import 'package:appwrite_boilerplate/app/models/admin_stats_model.dart';

abstract class DashboardRepoInterface {
  Future<AdminStatsModel> getStats();
}
