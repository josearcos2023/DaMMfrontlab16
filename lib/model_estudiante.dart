class Character {
  final int? id;
  final String name;
  final int age;
  final DateTime birthday;
  final int classId;
  final int raceId;

  Character({
    this.id,
    required this.name,
    required this.age,
    required this.birthday,
    required this.classId,
    required this.raceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'birthday': birthday.toIso8601String(),
      'classId': {'id': classId},
      'raceId': {'id': raceId},
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      birthday: DateTime.parse(json['birthday']),
      classId: json['class']['id'],
      raceId: json['race']['id'],
    );
  }
}
