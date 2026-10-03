const pg = require('pg');
(async () => {
  const c = new pg.Client(process.env.DATABASE_URL);
  await c.connect();
  const items = await c.query('SELECT count(*) FROM articles');
  const selected = await c.query('SELECT count(*) FROM articles WHERE selected');
  const sources = await c.query('SELECT count(*) FROM sources');
  const latest = await c.query('SELECT created_at FROM articles ORDER BY created_at DESC LIMIT 1');
  await c.end();
  console.log(JSON.stringify({
    items: items.rows[0].count,
    selected: selected.rows[0].count,
    sources: sources.rows[0].count,
    latest: latest.rows[0]?.created_at || 'N/A'
  }));
})();
