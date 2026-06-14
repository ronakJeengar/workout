class Exercise {
  final String id;
  final String name;
  final String? description;
  final String? muscleGroup;

  const Exercise({
    required this.id,
    required this.name,
    this.description,
    this.muscleGroup,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? muscleGroup,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      muscleGroup: json['muscleGroup'] as String?,
    );
  }
}
