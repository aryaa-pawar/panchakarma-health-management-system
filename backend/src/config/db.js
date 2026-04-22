import mysql from "mysql2/promise";
import { env } from "./env.js";

export const pool = mysql.createPool({
  ...env.db,
  waitForConnections: true,
  connectionLimit: 10,
  namedPlaceholders: true
});

export async function query(sql, params = {}) {
  const [rows] = await pool.execute(sql, params);
  return rows;
}

export async function withAuditContext(userId, runner) {
  const connection = await pool.getConnection();
  try {
    await connection.query("SET @app_user_id := ?", [userId ?? null]);
    return await runner(connection);
  } finally {
    try {
      await connection.query("SET @app_user_id := NULL");
    } catch {
      // Ignore cleanup failures while releasing the connection.
    }
    connection.release();
  }
}

export async function queryWithAudit(sql, params = [], userId = null) {
  return withAuditContext(userId, async (connection) => {
    const [rows] = await connection.query(sql, params);
    return rows;
  });
}

export async function callProcedure(name, args = [], userId = null) {
  return withAuditContext(userId, async (connection) => {
    const placeholders = args.map(() => "?").join(", ");
    const statement = `CALL ${name}(${placeholders})`;
    const [rows] = await connection.query(statement, args);

    if (Array.isArray(rows) && rows.length && Array.isArray(rows[0])) {
      return rows[0];
    }

    return rows;
  });
}
