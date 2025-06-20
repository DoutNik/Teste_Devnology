import { useEffect, useState } from "react";
import { fetchAllProducts } from "../api/products";
import type { Product } from "../types/Product";
import { useCart } from "../context/CartContext";
import { Link } from "react-router-dom";
import styles from "./Home.module.css";

export default function Home() {
  const [products, setProducts] = useState<Product[]>([]);
  const [filtered, setFiltered] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchName, setSearchName] = useState("");
  const [searchDescription, setSearchDescription] = useState("");
  const [providerFilter, setProviderFilter] = useState<
    "all" | "brazilian" | "european"
  >("all");
  const [minPrice, setMinPrice] = useState<number | "">("");
  const [maxPrice, setMaxPrice] = useState<number | "">("");
  const [addedMessage, setAddedMessage] = useState<string | null>(null);
  const { addToCart } = useCart();

  useEffect(() => {
    fetchAllProducts().then((data) => {
      setProducts(data);
      setLoading(false);
    });
  }, []);

  const handleAddToCart = (product: Product) => {
    addToCart(product);
    setAddedMessage(`✅ ${product.name} adicionado ao carrinho`);
    setTimeout(() => setAddedMessage(null), 1500);
  };

  useEffect(() => {
    let filteredList = products;

    if (searchName.trim() !== "") {
      const searchLower = searchName.toLowerCase();
      filteredList = filteredList.filter((p) =>
        p.name?.toLowerCase().includes(searchLower)
      );
    }

    if (searchDescription.trim() !== "") {
      const descLower = searchDescription.toLowerCase();
      filteredList = filteredList.filter((p) =>
        p.description?.toLowerCase().includes(descLower)
      );
    }

    if (providerFilter !== "all") {
      filteredList = filteredList.filter((p) => p.provider === providerFilter);
    }

    if (minPrice !== "") {
      filteredList = filteredList.filter((p) => p.price >= Number(minPrice));
    }
    if (maxPrice !== "") {
      filteredList = filteredList.filter((p) => p.price <= Number(maxPrice));
    }

    setFiltered(filteredList);
  }, [
    searchName,
    searchDescription,
    providerFilter,
    minPrice,
    maxPrice,
    products,
  ]);

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <Link
          to="/carrinho"
          className={styles.linkCart}
          aria-label="Ver carrinho"
        >
          🛒 Ver Carrinho
        </Link>
      </header>

      <h1 className={styles.title}>Produtos</h1>

      <section className={styles.filters}>
        <input
          type="text"
          placeholder="Buscar por nome..."
          value={searchName}
          onChange={(e) => setSearchName(e.target.value)}
          className={styles.input}
          aria-label="Buscar por nome"
        />

        <input
          type="text"
          placeholder="Busca avançada na descrição..."
          value={searchDescription}
          onChange={(e) => setSearchDescription(e.target.value)}
          className={styles.input}
          aria-label="Busca avançada na descrição"
        />

        <select
          value={providerFilter}
          onChange={(e) =>
            setProviderFilter(
              e.target.value as "all" | "brazilian" | "european"
            )
          }
          className={styles.select}
          aria-label="Filtro de fornecedor"
        >
          <option value="all">Todos os fornecedores</option>
          <option value="brazilian">Brasileiro</option>
          <option value="european">Europeu</option>
        </select>

        <input
          type="number"
          placeholder="Preço mínimo"
          min={0}
          value={minPrice}
          onChange={(e) =>
            setMinPrice(e.target.value === "" ? "" : Number(e.target.value))
          }
          className={styles.inputNumber}
          aria-label="Preço mínimo"
        />

        <input
          type="number"
          placeholder="Preço máximo"
          min={0}
          value={maxPrice}
          onChange={(e) =>
            setMaxPrice(e.target.value === "" ? "" : Number(e.target.value))
          }
          className={styles.inputNumber}
          aria-label="Preço máximo"
        />
      </section>
      {addedMessage && (
        <div className={styles.alertSuccess} role="status">
          {addedMessage}
        </div>
      )}
      <main className={styles.productGrid} aria-live="polite">
        {loading ? (
          <p>Carregando produtos...</p>
        ) : filtered.length === 0 ? (
          <p className={styles.noResults}>Nenhum produto encontrado.</p>
        ) : (
          filtered.map((product) => (
            <article key={product.id} className={styles.productCard}>
              {product.image && product.image.trim() !== "" ? (
                <img
                  src={product.image}
                  alt={product.name}
                  className={styles.productImage}
                />
              ) : (
                <div className={styles.productImagePlaceholder}>
                  Sem imagem disponível
                </div>
              )}

              <h2 className={styles.productName}>{product.name}</h2>
              <p className={styles.productDescription}>{product.description}</p>
              <p className={styles.productPrice}>
                R$ {product.price.toFixed(2)}
              </p>
              <p className={styles.productProvider}>
                Fornecedor: {product.provider}
              </p>
              <button
                className={styles.btnAdd}
                onClick={() => handleAddToCart(product)}
                aria-label={`Adicionar ${product.name} ao carrinho`}
              >
                Adicionar ao carrinho
              </button>
            </article>
          ))
        )}
      </main>
    </div>
  );
}
