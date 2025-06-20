import type { Product } from "./Product";

export type CartItem = Product & {
  id: number;
  name: string;
  price: number;
  quantity: number;
};
