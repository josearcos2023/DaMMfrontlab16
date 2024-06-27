class Character {
  final int? id;
  final String name;
  final int age;
  final DateTime birthday;
  final String className;
  final String raceName;

  Character({
    this.id,
    required this.name,
    required this.age,
    required this.birthday,
    required this.className,
    required this.raceName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'birthday': birthday.toIso8601String(),
      'classId': {'name': className},
      'raceId': {'name': raceName},
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      birthday: DateTime.parse(json['birthday']),
      className: json['class']['name'],
      raceName: json['race']['name'],
    );
  }
}
