import 'package:sorting/entity/user_entity.dart';

// 当前登录的用户
UserEntity _currentUser;

void setCurrentUser(UserEntity user) {
  _currentUser = user;
}

UserEntity getCurrentUser() {
  return _currentUser;
}