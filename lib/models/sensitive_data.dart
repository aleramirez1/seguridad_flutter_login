class SensitiveData {
  final String userEmail;
  final String password;
  final String creditCard;
  final String ssn;

  SensitiveData({
    required this.userEmail,
    required this.password,
    required this.creditCard,
    required this.ssn,
  });

  factory SensitiveData.empty() {
    return SensitiveData(
      userEmail: '',
      password: '',
      creditCard: '',
      ssn: '',
    );
  }

  factory SensitiveData.sample() {
    return SensitiveData(
      userEmail: 'prueba@gmail.com',
      password: 'prueBa123',
      creditCard: '4532-1234-5678-9010',
      ssn: '123-45-6789',
    );
  }

  Map<String, String> toMap() {
    return {
      'user_email': userEmail,
      'password': password,
      'credit_card': creditCard,
      'ssn': ssn,
    };
  }

  factory SensitiveData.fromMap(Map<String, String> map) {
    return SensitiveData(
      userEmail: map['user_email'] ?? '',
      password: map['password'] ?? '',
      creditCard: map['credit_card'] ?? '',
      ssn: map['ssn'] ?? '',
    );
  }

  bool get isEmpty {
    return userEmail.isEmpty && password.isEmpty && creditCard.isEmpty && ssn.isEmpty;
  }
}
