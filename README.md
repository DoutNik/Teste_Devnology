# 🧪 Teste Técnico Fullstack — Devnology

Este projeto é uma solução completa de e-commerce desenvolvida como parte do processo seletivo da Devnology. Inclui:

* 🛒 Web em React
* 📱 App mobile em Flutter
* 🖥️ Backend opcional em Node.js + PostgreSQL com Docker

---

## 🔧 Tecnologias utilizadas

* **Frontend Web:** React + Vite + CSS Modules
* **App Mobile:** Flutter
* **Backend:** Node.js + Express
* **Banco de Dados:** PostgreSQL
* **Infraestrutura:** Docker & Docker Compose

---

## 🚀 Como rodar o projeto

1. Clonar o repositório:

```bash
git clone https://github.com/DoutNik/Teste_Devnology.git
cd Teste_Devnology
```

2. Backend + Banco de Dados (Docker)

```bash
cd backend
docker-compose up --build
```

O backend estará disponível em: http://localhost:3001

Se estiver usando emulador Android, o Flutter deve usar: http://10.0.2.2:3001

3. Web (React)

```bash
cd web
npm install
npm run dev
```

Disponível em http://localhost:5173
4. App Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

---

## ✅ Funcionalidades implementadas

✅ Listagem de produtos de 2 APIs
✅ Filtros por fornecedor e preço
✅ Carrinho de compras (adicionar, remover, quantidade)
✅ Finalização da compra
✅ Validações completas (nome, CPF, telefone, etc.)
✅ Registro dos pedidos no banco de dados
✅ Página de confirmação do pedido

---

## 🧠 Decisões técnicas

Utilizei Docker para facilitar a entrega com banco integrado.
React com CSS Modules para estilização rápida e responsiva.
Flutter para experiência mobile fluida e validações compartilhadas.
Backend opcional para centralizar dados e gerenciar os pedidos.
