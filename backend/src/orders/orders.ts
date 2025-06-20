import { Router, Request, Response } from 'express';
import pool from '../database';

const router = Router();
// @ts-ignore
router.post('/', async (req: Request, res: Response) => {
  const { customer_name, customer_email, customer_address, customer_phone, items } = req.body;

  if (!customer_name || !customer_email || !customer_address || !customer_phone || !items?.length) {
    return res.status(400).json({ error: 'Datos incompletos' });
  }

  try {
    // Insertar pedido y obtener id
    const orderResult = await pool.query(
      `INSERT INTO orders (customer_name, customer_email, customer_address, customer_phone, items)
       VALUES ($1, $2, $3, $4, $5) RETURNING id`,
      [customer_name, customer_email, customer_address, customer_phone, JSON.stringify(items)]
    );

    const orderId = orderResult.rows[0].id;

    // Consultar pedido completo con ese id
    const fullOrderResult = await pool.query(
      `SELECT * FROM orders WHERE id = $1`,
      [orderId]
    );

    const fullOrder = fullOrderResult.rows[0];

    // Parsear items JSON para devolver como objeto
   if (typeof fullOrder.items === "string") {
  fullOrder.items = JSON.parse(fullOrder.items);
}

    res.status(201).json({ message: 'Pedido creado', order: fullOrder });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear pedido' });
  }
});

export default router;
