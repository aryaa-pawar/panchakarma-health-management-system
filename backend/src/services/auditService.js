import { query } from "../config/db.js";

export async function createAuditLog({
  userId = null,
  action,
  entityType,
  entityId = null,
  metadata = null,
  ipAddress = null
}) {
  await query(
    `INSERT INTO audit_log (user_id, action, entity_type, entity_id, metadata, ip_address)
     VALUES (:userId, :action, :entityType, :entityId, :metadata, :ipAddress)`,
    {
      userId,
      action,
      entityType,
      entityId,
      metadata: metadata ? JSON.stringify(metadata) : null,
      ipAddress
    }
  );
}
