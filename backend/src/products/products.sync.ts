import pool from "../database";

const BRAZILIAN_API =
  "http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/brazilian_provider";
const EUROPEAN_API =
  "http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/european_provider";

function mapProducts(data: any[], provider: "brazilian" | "european") {
  return data.map((p: any) => ({
    id: `${provider === "brazilian" ? "br" : "eu"}-${p.id}`,
    provider,
    name: p.name ?? "Produto sem nome",
    description: p.description ?? "Sem descrição disponível.",
    price: Number(p.price) || 0,
    image: p.image ?? "",
  }));
}

export async function syncProducts() {
  try {
    const [brRes, euRes] = await Promise.all([
      fetch(BRAZILIAN_API),
      fetch(EUROPEAN_API),
    ]);

    if (!brRes.ok || !euRes.ok) {
      throw new Error("Una de las APIs no respondió correctamente");
    }

    const [brData, euData] = await Promise.all([brRes.json(), euRes.json()]);

    const allProducts = [
      ...mapProducts(brData, "brazilian"),
      ...mapProducts(euData, "european"),
    ];

    for (const p of allProducts) {
      await pool.query(
        `INSERT INTO products (id, provider, name, description, price, image)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (id) DO UPDATE SET
           provider = EXCLUDED.provider,
           name = EXCLUDED.name,
           description = EXCLUDED.description,
           price = EXCLUDED.price,
           image = EXCLUDED.image`,
        [p.id, p.provider, p.name, p.description, p.price, p.image]
      );
    }

    console.log("Productos sincronizados");
  } catch (err) {
    console.error("Error sincronizando productos:", err);
  }
}
