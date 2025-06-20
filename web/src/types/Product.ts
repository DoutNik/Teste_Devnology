export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  image: string;
  provider: 'brazilian' | 'european';
}