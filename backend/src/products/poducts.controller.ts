import { Router } from 'express';
import pool from '../database';
import { syncProducts } from './products.sync';

const router = Router();

router.get('/', async (req, res) => {
  try {
    await syncProducts(); 
    const result = await pool.query('SELECT * FROM products ORDER BY name');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener productos' });
  }
});

export default router;
