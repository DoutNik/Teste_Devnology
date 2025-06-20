import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

console.log('🌀 Pool de PostgreSQL criado');


pool.query('SELECT NOW()')
  .then(res => {
    console.log('Conexão bem-sucedida.', res.rows[0]);
  })
  .catch(err => {
    console.error('Erro ao conectar.', err);
  });

export default pool;
