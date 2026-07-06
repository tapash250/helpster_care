/// Route constants for the approvals feature.
class ApprovalRoutes {
  ApprovalRoutes._();

  static const approvalList = '/approvals';
  static String approvalDetail(String id) => '/approvals/$id';
}
