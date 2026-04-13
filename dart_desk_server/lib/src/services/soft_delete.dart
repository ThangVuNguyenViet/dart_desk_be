/// Utilities for soft delete operations.
///
/// Soft-deletable entities: Document, DocumentVersion, Project, User.
/// All other entities use hard delete.
class SoftDelete {
  /// Returns a timestamp for marking an entity as soft-deleted.
  static DateTime timestamp() => DateTime.now();

  /// Whether a deletedAt value indicates the record is soft-deleted.
  static bool isDeleted(DateTime? deletedAt) => deletedAt != null;
}
