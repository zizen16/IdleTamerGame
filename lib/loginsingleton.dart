import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idletamergame/models/creaturemodel.dart';
import 'package:idletamergame/models/login.dart';

class LoginSingleton {
  LoginSingleton._internal();

  static final LoginSingleton _instance = LoginSingleton._internal();

  factory LoginSingleton() => _instance;

  late Login login;

  void setLogin(Login logindata) {
    login = logindata;
  }

  Login getLogin() => login;

  void updateLogin(Login logindata) {
    setLogin(logindata);
  }

  Future<void> createUser(Login logindata) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(logindata.email)
        .get();

    if (userSnapshot.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A user with this email is already registered.',
      );
    }

    updateLogin(logindata);
    await saveLogin();
  }

  Future<void> saveLogin() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(login.email)
        .set(login.toJson());
  }

  Future<Login> loadLogin(String email) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(email).get();

    if (!snapshot.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'user-not-found',
        message: 'User not found in the database.',
      );
    }

    final data = snapshot.data()!;
    final loadedLogin = Login(
      email: data['email'] as String,
      password: data['password'] as String,
      name: data['name'] as String?,
      level: (data['level'] as num?)?.toInt() ?? 1,
      power: (data['power'] as num?)?.toInt() ?? 0,
      gold: (data['gold'] as num?)?.toInt() ?? 0,
      creatures: (data['creatures'] as List<dynamic>? ?? const [])
          .map((creatureData) => CreatureModel(
                name: creatureData['name'] as String,
                rarity: creatureData['rarity'] as String,
                description: creatureData['description'] as String,
                avatar: creatureData['avatar'] as String,
                power: (creatureData['power'] as num?)?.toDouble(),
                exp: (creatureData['exp'] as num?)?.toDouble(),
                level: (creatureData['level'] as num?)?.toInt(),
                goldGen: (creatureData['goldGen'] as num?)?.toInt(),
                hunger: (creatureData['hunger'] as num?)?.toDouble(),
              ))
          .toList(),
    );

    setLogin(loadedLogin);
    return loadedLogin;
  }

  Future<Login> authenticate(String email, String password) async {
    final savedLogin = await loadLogin(email);

    if (savedLogin.password != password) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'invalid-password',
        message: 'The password is incorrect.',
      );
    }

    return savedLogin;
  }

  void addCreature(CreatureModel creature) {
    login.creatures.add(creature);
  }

  void removeCreature(CreatureModel creature) {
    login.creatures.remove(creature);
  }
}