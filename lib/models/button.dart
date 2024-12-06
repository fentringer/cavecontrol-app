class ButtonState {
  final int id;
  final bool isActive;

  ButtonState({required this.id, required this.isActive});

  factory ButtonState.fromJson(Map<String, dynamic> json) {
    return ButtonState(
      id: json['id'],
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isActive': isActive,
    };
  }
}
