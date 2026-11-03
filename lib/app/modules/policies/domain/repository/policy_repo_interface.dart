import 'package:appwrite_boilerplate/app/models/privacy_policy_model.dart';

abstract class PolicyRepoInterface {
  Future<PrivacyPolicyModel> getPolicies();
}
