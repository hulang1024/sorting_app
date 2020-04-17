import 'package:sorting/entity/user_entity.dart';

UserEntity _currentUser;

void setCurrentUser(UserEntity user) {
  _currentUser = user;
}

UserEntity getCurrentUser() {
  return _currentUser;
}