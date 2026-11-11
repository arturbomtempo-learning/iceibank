enum UserRole {
  manager(apiValue: 'admin', label: 'Gerente'),
  customer(apiValue: 'cliente', label: 'Correntista');

  const UserRole({required this.apiValue, required this.label});

  final String apiValue;
  final String label;

  static UserRole? fromApiValue(Object? value) {
    for (final role in values) {
      if (role.apiValue == value) return role;
    }

    return null;
  }
}
