class PasswordModel {
  String key;
  String title;
  String password;
  bool hidden;

  PasswordModel({
    this.key = '',
    required this.title,
    required this.password,
    this.hidden = true,
  });

  factory PasswordModel.fromMap(String key, Map map) => PasswordModel(
        title: map['title'],
        password: map['password'],
        key: key,
      );

  Map toJson() => {
        'title': title,
        'password': password,
      };
}
