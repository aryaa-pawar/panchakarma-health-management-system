import app from "./app.js";
import { env } from "./config/env.js";
import { pool } from "./config/db.js";

async function bootstrap() {
  await pool.query("SELECT 1");
  app.listen(env.port, () => {
    console.log(`Server running on port ${env.port}`);
  });
}

bootstrap().catch((error) => {
  console.error("Failed to start server", error);
  process.exit(1);
});
