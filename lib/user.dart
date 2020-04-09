class User {
  int _id;
  String _name;
  String _phone;

  User({id, name, phone}) : _id = id, _name = name, _phone = phone;

  get id => _id;
  get name => _name;
  get phone => _phone;
}

User _currentUser;

void setCurrentUser(User user) {
  _currentUser = user;
}

User getCurrentUser() {
  assert (_currentUser != null);
  return _currentUser;
}