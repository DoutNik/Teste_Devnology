class Address {
  String street;
  String number;
  String? complement;
  String neighborhood;
  String city;
  String state;
  String cep;

  Address({
    this.street = '',
    this.number = '',
    this.complement,
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.cep = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'cep': cep,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      number: json['number'] ?? '',
      complement: json['complement'],
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      cep: json['cep'] ?? '',
    );
  }
}
