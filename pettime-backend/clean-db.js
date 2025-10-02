/* Uso:
   - Configure a conexão via DATABASE_URL ou DB_DIALECT/DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASS.
   - Por padrão preserva:
       - Tabelas: SequelizeMeta, SequelizeData
       - Admin: tabela 'users', registro com id = 1
   - Opcional:
       EXCLUDE_TABLES="SequelizeMeta,SequelizeData,minha_tabela"
       ADMIN_TABLE="users"
       ADMIN_ID="1"
   - Execute: node scripts/clean-db.js
*/
const { Sequelize } = require('sequelize');

function getSequelizeFromEnv() {
  const url = process.env.DATABASE_URL;
  if (url) return new Sequelize(url, { logging: false });
  const dialect = process.env.DB_DIALECT || 'mysql';
  return new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASS,
    {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined,
      dialect,
      logging: false,
    }
  );
}

function quoteIdentForDialect(dialect, name) {
  if (dialect === 'mysql' || dialect === 'mariadb') return `\`${name}\``;
  return `"${name}"`;
}

async function main() {
  const sequelize = getSequelizeFromEnv();
  const qi = sequelize.getQueryInterface();
  const dialect = sequelize.getDialect();

  const excluded = new Set(
    (process.env.EXCLUDE_TABLES || 'SequelizeMeta,SequelizeData')
      .split(',')
      .map(s => s.trim().toLowerCase())
      .filter(Boolean)
  );
  const adminTable = (process.env.ADMIN_TABLE || 'users').toLowerCase();
  const adminId = process.env.ADMIN_ID || '1';

  await sequelize.authenticate();

  let tables = await qi.showAllTables();
  tables = tables.map(t => (typeof t === 'string' ? t : (t.tableName || t.name || String(t))));
  const q = (n) => quoteIdentForDialect(dialect, n);

  // Desativar FKs
  if (dialect === 'mysql' || dialect === 'mariadb') await sequelize.query('SET FOREIGN_KEY_CHECKS=0');
  if (dialect === 'sqlite') await sequelize.query('PRAGMA foreign_keys = OFF');

  for (const table of tables) {
    const tableLower = String(table).toLowerCase();
    if (excluded.has(tableLower)) {
      console.log(`Pulando tabela preservada: ${table}`);
      continue;
    }

    try {
      if (tableLower === adminTable) {
        // Preserva admin por id
        const sql = `DELETE FROM ${q(table)} WHERE id <> ${adminId}`;
        console.log(`Limpando ${table} (preservando id=${adminId})`);
        await sequelize.query(sql);
      } else {
        if (dialect === 'postgres') {
          console.log(`TRUNCATE ${table} (RESTART IDENTITY CASCADE)`);
          await sequelize.query(`TRUNCATE TABLE ${q(table)} RESTART IDENTITY CASCADE`);
        } else if (dialect === 'mysql' || dialect === 'mariadb') {
          console.log(`TRUNCATE ${table}`);
          await sequelize.query(`TRUNCATE TABLE ${q(table)}`);
        } else if (dialect === 'sqlite') {
          console.log(`DELETE FROM ${table}`);
          await sequelize.query(`DELETE FROM ${q(table)}`);
          await sequelize.query(`DELETE FROM sqlite_sequence WHERE name=${sequelize.escape(table)}`).catch(() => {});
        } else {
          console.log(`DELETE FROM ${table}`);
          await sequelize.query(`DELETE FROM ${q(table)}`);
        }
      }
    } catch (err) {
      console.error(`Falha ao limpar tabela ${table}: ${err.message}`);
    }
  }

  // Reativar FKs
  if (dialect === 'mysql' || dialect === 'mariadb') await sequelize.query('SET FOREIGN_KEY_CHECKS=1');
  if (dialect === 'sqlite') await sequelize.query('PRAGMA foreign_keys = ON');

  await sequelize.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
