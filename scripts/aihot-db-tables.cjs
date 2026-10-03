const pg = require('pg');
(async () => {
  const c = new pg.Client(process.env.DATABASE_URL);
  await c.connect();
  const tables = await c.query("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename");
  await c.end();
  tables.rows.forEach(r => console.log('  ' + r.tablename));
})();
