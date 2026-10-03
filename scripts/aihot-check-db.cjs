const pg = require('pg');
(async () => {
  const c = new pg.Client(process.env.DATABASE_URL);
  await c.connect();
  const dbCheck = await c.query('SELECT current_database()');
  const tableCheck = await c.query("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'articles')");
  await c.end();
  console.log(JSON.stringify({
    database: dbCheck.rows[0].current_database,
    hasTable: tableCheck.rows[0].exists
  }));
})();
