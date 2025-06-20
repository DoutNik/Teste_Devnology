const validStates = [
  "AC","AL","AP","AM","BA","CE","DF","ES","GO","MA",
  "MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN",
  "RS","RO","RR","SC","SP","SE","TO"
];

export const validateName = (name: string): string | null => {
  const trimmed = name.trim();

  if (trimmed.length === 0) return 'Nome é obrigatório';
  if (trimmed.length < 5) return 'Digite o nome completo';

  const parts = trimmed.split(/\s+/);
  if (parts.length < 2) return 'Digite o nome completo';

  const validWords = parts.filter(part => /^[A-Za-zÀ-ÖØ-öø-ÿ]{2,}$/.test(part));
  if (validWords.length < 2) return 'Cada parte do nome deve conter apenas letras';

  if (!/^[A-ZÀ-Ö]/.test(parts[0])) return 'O nome deve começar com letra maiúscula';

  return null;
};

export const validateEmail = (email: string): string | null => {
  if (!email.trim()) return 'Email é obrigatório';
  if (!/\S+@\S+\.\S+/.test(email)) return 'Email inválido';
  return null;
};

export const validatePhone = (phone: string): string | null => {
  const cleaned = phone.replace(/\s+/g, '');
  if (!cleaned) return 'Telefone é obrigatório';
  if (!/^\+?[1-9]\d{7,14}$/.test(cleaned)) {
    return 'Telefone inválido. Use formato internacional, ex: +5511999999999';
  }
  return null;
};

export const validateCPF = (cpf: string): string | undefined => {
  cpf = cpf.replace(/[^\d]+/g, "");
  if (cpf.length !== 11) return "CPF inválido";

  // Verifica CPFs com todos dígitos iguais
  if (/^(\d)\1{10}$/.test(cpf)) return "CPF inválido";

  let sum = 0;
  let rest;

  for (let i = 1; i <= 9; i++) {
    sum += parseInt(cpf.substring(i - 1, i)) * (11 - i);
  }
  rest = (sum * 10) % 11;
  if (rest === 10 || rest === 11) rest = 0;
  if (rest !== parseInt(cpf.substring(9, 10))) return "CPF inválido";

  sum = 0;
  for (let i = 1; i <= 10; i++) {
    sum += parseInt(cpf.substring(i - 1, i)) * (12 - i);
  }
  rest = (sum * 10) % 11;
  if (rest === 10 || rest === 11) rest = 0;
  if (rest !== parseInt(cpf.substring(10, 11))) return "CPF inválido";

  return undefined;
};


export const validateAddress = (address: {
  street: string;
  number: string;
  complement?: string;
  neighborhood: string;
  city: string;
  state: string;
  cep: string;
}): Record<string, string> => {
  const errors: Record<string, string> = {};

  if (!address.street.trim()) errors.street = 'Rua é obrigatória';
  if (!address.number.trim()) {
    errors.number = 'Número é obrigatório';
  } else if (address.number !== 'S/N' && !/^\d+$/.test(address.number.trim())) {
    errors.number = 'Número inválido';
  }
  if (!address.neighborhood.trim()) errors.neighborhood = 'Bairro é obrigatório';
  if (!address.city.trim()) errors.city = 'Cidade é obrigatória';
  if (!validStates.includes(address.state.toUpperCase())) errors.state = 'Estado inválido';
  if (!/^\d{5}-?\d{3}$/.test(address.cep)) errors.cep = 'CEP inválido';

  return errors;
};

