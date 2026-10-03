const pg = require('pg');
(async () => {
  try {
    const c = new pg.Client(process.env.DATABASE_URL);
    await c.connect();
    const r = await c.query('SELECT 1 as test');
    await c.end();
    console.log('OK');
  } catch (e) {
    console.error('ERROR: ' + e.message);
    process.exit(1);
  }
})();
