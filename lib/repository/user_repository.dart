import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_analyzer/api/api_connection.dart';
import 'package:voice_analyzer/model/user_model.dart';

class UserRepository {
  static final UserRepository _userRepository = UserRepository._internal();

  factory UserRepository() {
    return _userRepository;
  }

  UserRepository._internal();

  static Future<SharedPreferences> _sharedPreferences =
      SharedPreferences.getInstance();

  Future<bool> isAuthorized() async {
    final sp = await _sharedPreferences;
    bool contains = sp.containsKey('user_name') && sp.containsKey('password');
    if (contains && sp.getString('user_name') != null)
      return Future.value(true);
    else
      return Future.value(false);
  }

  static Future<bool> isFirstOpened() async {
    final sp = await _sharedPreferences;
    bool contains = sp.containsKey('isFirstOpened');
    if ((contains && sp.getBool('isFirstOpened') != null) || sp.getBool('isFirstOpened') == false)
      return false;
    else
      return true;
  }

  static void setFirstOpened(bool b) async {
    final sp = await _sharedPreferences;
    sp.setBool('isFirstOpened', b);
  }

  Future<void> saveUser({@required User user}) async {
    final sp = await _sharedPreferences;
    sp.setInt('id', user.id);
    sp.setString('user_name', user.username);
    sp.setString('password', user.password);
    sp.setString('email', user.email);
  }

  Future<bool> deleteUser() async {
    final sp = await _sharedPreferences;
    return sp.clear();
  }

  Future<void> createUser(
      {String username, String password, String email}) async {
    ApiConnection _api = ApiConnection();
    _api.createUser(username: username, password: password, email: email);
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<User> authenticate({String username, String password}) async {
    ApiConnection _api = ApiConnection();
    final responseData =
        await _api.getUser(username: username, password: password);
    if (responseData is int) {
      return User(
          id: responseData,
          username: username,
          password: password,
          email: 'emailTest');
    } else {
      throw Exception('Invalid user');
    }
  }

  static Future<int> getId() async {
    final sp = await _sharedPreferences;
    return sp.getInt('id');
  }

  static Future<void> setId(int id) async {
    final sp = await _sharedPreferences;
    sp.setInt('id', id);
  }

  static Future<User> getUser() async {
    final sp = await _sharedPreferences;
    int id = sp.getInt('id');
    String username = sp.getString('user_name');
    String password = sp.getString('password');
    String email = sp.getString('email');

    return User(id: id, username: username, password: password, email: email);
  }

  static Future<String> getUserName() async {
    final sp = await _sharedPreferences;
    String username = sp.getString('user_name');

    return username;
  }
}
