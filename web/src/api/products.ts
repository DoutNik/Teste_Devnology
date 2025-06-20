const BACKEND_API = import.meta.env.VITE_API_URL || 'http://localhost:3001';

export async function fetchAllProducts() {
  try {
    const res = await fetch(`${BACKEND_API}/products`);

    if (!res.ok) {
      throw new Error("No se pudieron obtener los productos del backend");
    }

    const data = await res.json();
    

    return data.map((p: any) => ({
      id: p.id,
      provider: p.provider ?? "unknown",
      name: p.name ?? 'Produto sem nome',
      description: p.description ?? 'Sem descrição disponível.',
      price: Number(p.price) || 0,
      image: p.image,
    }));
  } catch (error) {
    console.error("Error al obtener productos desde el backend:", error);
    return [];
  }
}
