import React from "react";
import { useCart } from "../context/CartContext";
import { useNavigate } from "react-router-dom";
import styles from "./CartPage.module.css";
import { Link } from "react-router-dom";

const CartPage: React.FC = () => {
  const { items, removeFromCart, incrementQuantity, decrementQuantity } =
    useCart();

  const navigate = useNavigate();

  const total = items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  );

  const handleGoToCheckout = () => {
    navigate("/checkout");
  };

  return (
    <div className={styles.container}>
      <h2 className={styles.title}>Carrinho de Compras</h2>

      {items.length === 0 ? (
        <>
          <p className={styles.emptyMessage}>O carrinho está vazio.</p>
          <Link to="/" className={styles.backLink}>
            ← Voltar para produtos
          </Link>
        </>
      ) : (
        <>
          <ul className={styles.list}>
            {items.map((item) => (
              <li key={item.id} className={styles.item}>
                {item.image && item.image.trim() !== "" ? (
                <img
                  src={item.image}
                  alt={item.name}
                  className={styles.itemImage}
                />
              ) : (
                <div className={styles.itemImagePlaceholder}>
                  Sem imagem disponível
                </div>
              )}
                <div className={styles.details}>
                  <p>
                    <strong>{item.name}</strong>
                  </p>
                  <p>R$ {item.price.toFixed(2)}</p>
                  <div className={styles.quantityControls}>
                    <button onClick={() => decrementQuantity(item.id)}>
                      -
                    </button>
                    <span>{item.quantity}</span>
                    <button onClick={() => incrementQuantity(item.id)}>
                      +
                    </button>
                  </div>
                </div>
                <button
                  className={styles.removeButton}
                  onClick={() => removeFromCart(item.id)}
                >
                  Remover
                </button>
              </li>
            ))}
          </ul>
          <hr className={styles.hr} />
          <p className={styles.total}>Total: R$ {total.toFixed(2)}</p>
          <button
            className={styles.checkoutButton}
            onClick={handleGoToCheckout}
          >
            Finalizar compra
          </button>
          <Link to="/" className={styles.backLink}>
            ← Voltar para produtos
          </Link>
        </>
      )}
    </div>
  );
};

export default CartPage;
