class SettingEntity {
  int? id;
  int color;
  bool darkMode;

  SettingEntity({this.id, this.color = 4288423856, this.darkMode = false});

  factory SettingEntity.fromMap(Map<String, Object?> map) {
    return SettingEntity(
      id: map['id'] as int?,
      color: map['color'] as int? ?? 4288423856,
      darkMode: (map['dark_mode'] as int?) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'color': color,
      'dark_mode': darkMode ? 1 : 0,
    };
  }
}
