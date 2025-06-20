import React, { useState, useRef } from "react";
import { useCart } from "../context/CartContext";
import styles from "./CheckoutPage.module.css";
import { Link, useNavigate } from "react-router-dom";
import {
  validateName,
  validateEmail,
  validatePhone,
  validateAddress,
  validateCPF,
} from "../utils/validation";

type FormData = {
  name: string;
  email: string;
  phone: string;
  cpf: string;
  address: {
    street: string;
    number: string;
    complement?: string;
    neighborhood: string;
    city: string;
    state: string;
    cep: string;
  };
};

const CheckoutPage: React.FC = () => {
  const { items, clearCart } = useCart();
  const navigate = useNavigate();

  const [formData, setFormData] = useState<FormData>({
    name: "",
    email: "",
    phone: "",
    cpf: "",
    address: {
      street: "",
      number: "",
      complement: "",
      neighborhood: "",
      city: "",
      state: "",
      cep: "",
    },
  });

  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [errors, setErrors] = useState<Record<string, string | undefined>>({});
  const [orderPlaced, setOrderPlaced] = useState(false);
  const [orderItems, setOrderItems] = useState<typeof items>([]);

  const nameRef = useRef<HTMLInputElement>(null);
  const emailRef = useRef<HTMLInputElement>(null);
  const phoneRef = useRef<HTMLInputElement>(null);
  const addressRef = useRef<HTMLTextAreaElement>(null);

  if (items.length === 0 && !orderPlaced) {
    return (
      <div className={styles.emptyCart}>
        <p>
          Seu carrinho está vazio. Adicione produtos para finalizar a compra.
        </p>
        <Link to="/carrinho" className={styles.backLink}>
          Voltar para carrinho
        </Link>
      </div>
    );
  }

  const fetchAddressFromCep = async (cep: string) => {
    const cleanedCep = cep.replace(/\D/g, "");
    if (cleanedCep.length !== 8) return;

    try {
      const res = await fetch(`https://viacep.com.br/ws/${cleanedCep}/json/`);
      const data = await res.json();
      if (!data.erro) {
        setFormData((prev) => ({
          ...prev,
          address: {
            ...prev.address,
            street: data.logradouro || "",
            neighborhood: data.bairro || "",
            city: data.localidade || "",
            state: data.uf || "",
          },
        }));
      }
    } catch (error) {
      console.error("Erro ao buscar CEP", error);
    }
  };

  const validate = (): boolean => {
    const newErrors: Record<string, string | undefined> = {
      name: validateName(formData.name) || undefined,
      email: validateEmail(formData.email) || undefined,
      phone: validatePhone(formData.phone) || undefined,
    };

    const addressErrors = validateAddress(formData.address);
    Object.entries(addressErrors).forEach(([key, msg]) => {
      newErrors[`address.${key}`] = msg;
    });

    setErrors(newErrors);
    return Object.values(newErrors).every((error) => !error);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;

    if (name.startsWith("address.")) {
      const addressField = name.split(".")[1] as keyof FormData["address"];

      // Actualizo el estado de forma segura usando el estado anterior
      setFormData((prev) => {
        const newAddress = {
          ...prev.address,
          [addressField]: value,
        };

        // Si el campo es CEP y tiene 8 dígitos, podés llamar a fetchAddressFromCep aquí (opcional)
        if (addressField === "cep") {
          const cleanedCep = value.replace(/\D/g, "");
          if (cleanedCep.length === 8) {
            fetchAddressFromCep(cleanedCep);
          }
        }

        // Actualizo el formData completo
        return {
          ...prev,
          address: newAddress,
        };
      });

      if (touched[name]) {
        // Uso una función que reciba la dirección actualizada, no formData (que puede estar desactualizado)
        const addressErrors = validateAddress({
          ...formData.address,
          [addressField]: value,
        });

        setErrors((prev) => ({
          ...prev,
          [name]: addressErrors[addressField],
        }));
      }
    } else {
      setFormData((prev) => ({ ...prev, [name]: value }));

      if (touched[name]) {
        let error = "";
        if (name === "name") error = validateName(value) || "";
        else if (name === "email") error = validateEmail(value) || "";
        else if (name === "phone") error = validatePhone(value) || "";
        else if (name === "cpf") error = validateCPF(value) || "";

        setErrors((prev) => ({ ...prev, [name]: error || undefined }));
      }
    }
  };

  const handleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
    const { name } = e.target;
    setTouched((prev) => ({ ...prev, [name]: true }));

    if (name.startsWith("address.")) {
      const addressField = name.split(".")[1] as keyof FormData["address"];
      const addressErrors = validateAddress(formData.address);
      setErrors((prev) => ({
        ...prev,
        [name]: addressErrors[addressField] || undefined,
      }));
    } else {
      let error = "";
      if (name === "name") error = validateName(formData.name) || "";
      if (name === "email") error = validateEmail(formData.email) || "";
      if (name === "phone") error = validatePhone(formData.phone) || "";

      setErrors((prev) => ({ ...prev, [name]: error || undefined }));
    }
  };

 

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    setTouched({
      name: true,
      email: true,
      phone: true,
      "address.street": true,
      "address.number": true,
      "address.neighborhood": true,
      "address.city": true,
      "address.state": true,
      "address.cep": true,
    });

    if (!validate()) {
      if (errors.name) nameRef.current?.focus();
      else if (errors.email) emailRef.current?.focus();
      else if (errors.phone) phoneRef.current?.focus();
      else if (Object.keys(errors).some((key) => key.startsWith("address.")))
        addressRef.current?.focus();
      return;
    }

    const payload = {
      customer_name: formData.name,
      customer_email: formData.email,
      customer_phone: formData.phone,
      customer_address: JSON.stringify(formData.address),
      items: items.map((item) => ({
        product_id: item.id,
        name: item.name,
        provider: item.provider,
        price: item.price,
        description: item.description,
        image: item.image,
        quantity: item.quantity,
      })),
    };

    try {
      const res = await fetch("http://localhost:3001/orders", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!res.ok) {
        const errData = await res.json();
        throw new Error(errData.error || "Erro ao enviar pedido");
      }

      const data = await res.json();
      console.log("Pedido registrado:", data);

      setOrderItems([...items]);
      clearCart();
      setOrderPlaced(true);
    } catch (error) {
      alert(`Erro ao enviar pedido: ${(error as Error).message}`);
    }
  };

   if (orderPlaced) {
    return (
      <div className={styles.confirmation}>
        <h2>Obrigado pela compra!</h2>
        <p>Seu pedido foi registrado com sucesso.</p>

        <h3>Dados do Cliente</h3>
        <p>
          <strong>Nome:</strong> {formData.name}
        </p>
        <p>
          <strong>Email:</strong> {formData.email}
        </p>
        <p>
          <strong>Telefone:</strong> {formData.phone}
        </p>

        <h3>Endereço</h3>
        <p>
          {formData.address.street}, {formData.address.number}
          {formData.address.complement && ` (${formData.address.complement})`}
        </p>
        <p>
          {formData.address.neighborhood} - {formData.address.city}/
          {formData.address.state}
        </p>
        <p>CEP: {formData.address.cep}</p>

        <h3>Produtos</h3>
        <ul>
          {orderItems.map((item: any, index: number) => (
            <li key={index} style={{ marginBottom: "1rem" }}>
              <strong>{item.name}</strong> ({item.provider})<br />
              {item.description}
              <br />
              Quantidade: {item.quantity}
              <br />
              Preço unitário: R$ {item.price.toFixed(2)}
              <br />
              Total: R$ {(item.price * item.quantity).toFixed(2)}
            </li>
          ))}
        </ul>

        <button className={styles.goHomeButton} onClick={() => navigate("/")}>
          Voltar para página inicial
        </button>
      </div>
    );
  }

  return (
    <form className={styles.form} onSubmit={handleSubmit} noValidate>
      <h2>Finalizar Compra</h2>

      <label>
        Nome:
        <input
          type="text"
          name="name"
          value={formData.name}
          onChange={handleChange}
          onBlur={handleBlur}
          ref={nameRef}
          aria-invalid={!!errors.name}
          aria-describedby="name-error"
        />
        {touched.name && errors.name && (
          <span id="name-error" className={styles.error}>
            {errors.name}
          </span>
        )}
      </label>

      <label>
        CPF:
        <input
          type="text"
          name="cpf"
          value={formData.cpf}
          onChange={handleChange}
          onBlur={handleBlur}
          placeholder="000.000.000-00"
          aria-invalid={!!errors.cpf}
          aria-describedby="cpf-error"
        />
        {touched.cpf && errors.cpf && (
          <span id="cpf-error" className={styles.error}>
            {errors.cpf}
          </span>
        )}
      </label>

      <label>
        Email:
        <input
          type="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          onBlur={handleBlur}
          ref={emailRef}
          aria-invalid={!!errors.email}
          aria-describedby="email-error"
        />
        {touched.email && errors.email && (
          <span id="email-error" className={styles.error}>
            {errors.email}
          </span>
        )}
      </label>

      <label>
        Telefone:
        <input
          type="tel"
          name="phone"
          value={formData.phone}
          onChange={handleChange}
          onBlur={handleBlur}
          ref={phoneRef}
          placeholder="+5511999999999"
          aria-invalid={!!errors.phone}
          aria-describedby="phone-error"
          inputMode="tel"
          pattern="\+?[0-9\s]*"
        />
        {touched.phone && errors.phone && (
          <span id="phone-error" className={styles.error}>
            {errors.phone}
          </span>
        )}
      </label>

      <h3>Endereço</h3>

      <label>
        CEP:
        <input
          type="text"
          name="address.cep"
          value={formData.address.cep}
          onChange={handleChange}
          onBlur={handleBlur}
          aria-invalid={!!errors["address.cep"]}
          aria-describedby="address-cep-error"
          maxLength={9}
        />
        {touched["address.cep"] && errors["address.cep"] && (
          <span id="address-cep-error" className={styles.error}>
            {errors["address.cep"]}
          </span>
        )}
      </label>

      <label>
        Rua:
        <input
          type="text"
          name="address.street"
          value={formData.address.street}
          onChange={handleChange}
          onBlur={handleBlur}
          aria-invalid={!!errors["address.street"]}
          aria-describedby="address-street-error"
        />
        {touched["address.street"] && errors["address.street"] && (
          <span id="address-street-error" className={styles.error}>
            {errors["address.street"]}
          </span>
        )}
      </label>

      <label>
        Número:
        <input
          type="text"
          name="address.number"
          value={formData.address.number}
          onChange={handleChange}
          onBlur={handleBlur}
          aria-invalid={!!errors["address.number"]}
          aria-describedby="address-number-error"
        />
        {touched["address.number"] && errors["address.number"] && (
          <span id="address-number-error" className={styles.error}>
            {errors["address.number"]}
          </span>
        )}
      </label>

      <label>
        Complemento (opcional):
        <input
          type="text"
          name="address.complement"
          value={formData.address.complement}
          onChange={handleChange}
          onBlur={handleBlur}
        />
      </label>

      <label>
        Bairro:
        <input
          type="text"
          name="address.neighborhood"
          value={formData.address.neighborhood}
          onChange={handleChange}
          onBlur={handleBlur}
          aria-invalid={!!errors["address.neighborhood"]}
          aria-describedby="address-neighborhood-error"
        />
        {touched["address.neighborhood"] && errors["address.neighborhood"] && (
          <span id="address-neighborhood-error" className={styles.error}>
            {errors["address.neighborhood"]}
          </span>
        )}
      </label>

      <label>
        Cidade:
        <input
          type="text"
          name="address.city"
          value={formData.address.city}
          onChange={handleChange}
          onBlur={handleBlur}
          aria-invalid={!!errors["address.city"]}
          aria-describedby="address-city-error"
        />
        {touched["address.city"] && errors["address.city"] && (
          <span id="address-city-error" className={styles.error}>
            {errors["address.city"]}
          </span>
        )}
      </label>

      <label>
        Estado (UF):
        <input
          type="text"
          name="address.state"
          value={formData.address.state}
          onChange={handleChange}
          onBlur={handleBlur}
          maxLength={2}
          aria-invalid={!!errors["address.state"]}
          aria-describedby="address-state-error"
        />
        {touched["address.state"] && errors["address.state"] && (
          <span id="address-state-error" className={styles.error}>
            {errors["address.state"]}
          </span>
        )}
      </label>

      <button type="submit" className={styles.submitButton}>
        Enviar Pedido
      </button>

      <Link to="/carrinho" className={styles.backLink}>
        ← Voltar para carrinho
      </Link>
    </form>
  );
};

export default CheckoutPage;
