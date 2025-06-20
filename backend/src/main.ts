import express from 'express';
import cors from 'cors';
import productsRouter from './products/poducts.controller';
import ordersRouter from './orders/orders';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/products', productsRouter);
app.use('/orders', ordersRouter);

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Servidor ouvindo na porta ${PORT}`);
});
