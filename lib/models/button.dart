class ButtonState {
  final int id;
  final bool isActive;

  ButtonState({required this.id, required this.isActive});

  // Construtor de fábrica para criar ButtonState a partir de JSON
  factory ButtonState.fromJson(Map<String, dynamic> json) {
    return ButtonState(
      id: json['id'], // Garantir que 'id' está presente no JSON
      isActive: json['isActive'] ?? false, // Se 'isActive' for null, define como false
    );
  }

  // Converte ButtonState para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isActive': isActive,
    };
  }
}
