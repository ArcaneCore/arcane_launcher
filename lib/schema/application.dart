class ApplicationEntity {
  int? id;
  String name;
  String path;
  String description;

  ApplicationEntity({
    this.id,
    this.name = '',
    this.path = '',
    this.description = '',
  });

  factory ApplicationEntity.fromMap(Map<String, Object?> map) {
    return ApplicationEntity(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      path: map['path'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'path': path,
      'description': description,
    };
  }
}
