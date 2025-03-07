import pg from "pg";

const pool = new pg.Pool({
  user: process.env.PGUSER || "wushu",
  host: process.env.PGHOST || "localhost",
  database: process.env.PGDATABASE || "wushu",
  password: process.env.PGPASSWORD || "Canguru-7",
  port: process.env.PGPORT || 5432,
  ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false
});

export default pool;