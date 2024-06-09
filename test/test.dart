void main(List<String> args) {
  const person = Person(firstname: 'bob', lastname: 'john');
  print(person.firstname);
  print(person.fullname);
}

mixin HasFirstName {
  String get firstname;
}
mixin HasLastName {
  String get lastname;
}
mixin HasFullName on HasFirstName, HasLastName {
  String get fullname => '$firstname $lastname';
}

class Person with HasFirstName, HasLastName, HasFullName {
  @override
  final String firstname;

  @override
  final String lastname;
  const Person({
    required this.firstname,
    required this.lastname,
  });
}
