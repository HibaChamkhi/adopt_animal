import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> signIn(UserEntity user);

  Future<void> signOut();

  Future<void> signUp(UserEntity user);

  Future<void> getUpdateUser(UserEntity user);

  Future<void> googleAuth();

  Future<void> getCreateCurrentUser(UserEntity user);

  Future<bool> isSignIn();

  Future<String> getCurrentUId();

  Stream<List<UserEntity>> getAllUsers(UserEntity user);

  Stream<List<UserEntity>> getSingleUser(UserEntity user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl(
      {required this.fireStore,
      required this.auth,
      required this.googleSignIn});

  @override
  Future<void> signIn(UserEntity user) async {
    await auth.signInWithEmailAndPassword(
        email: user.email!, password: user.password!);
  }

  @override
  Future<void> signUp(UserEntity user) async {
    await auth
        .createUserWithEmailAndPassword(
            email: user.email!, password: user.password!)
        .then((value) {
       getCreateCurrentUser(user);
    });
  }

  @override
  Stream<List<UserEntity>> getAllUsers(UserEntity user) {
    final userCollection = fireStore.collection("users");

    return userCollection
        .where("uid", isNotEqualTo: user.uid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    });
  }

  @override
  Future<void> getCreateCurrentUser(UserEntity user) async {
    final userCollection = fireStore.collection("users");

    final uid = await getCurrentUId();

    userCollection.doc(uid).get().then((userDoc) {
      if (!userDoc.exists) {
        final newUser = UserModel(
          email: user.email,
          uid: uid,
          status: user.status,
          profileUrl: user.profileUrl,
          name: user.name,
        ).toDocument();

        userCollection.doc(uid).set(newUser);
      } else {
        print("User already exists");
        return;
      }
    });
  }

  @override
  Future<String> getCurrentUId() async => auth.currentUser!.uid;

  @override
  Stream<List<UserEntity>> getSingleUser(UserEntity user) {
    final userCollection = fireStore.collection("users");

    return userCollection
        .limit(1)
        .where("uid", isEqualTo: user.uid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    });
  }

  @override
  Future<void> getUpdateUser(UserEntity user) async {
    final userCollection = fireStore.collection("users");

    Map<String, dynamic> userInformation = Map();

    if (user.profileUrl != null && user.profileUrl != "") {
      userInformation['profileUrl'] = user.profileUrl;
    }

    if (user.status != null && user.status != "") {
      userInformation['status'] = user.status;
    }

    if (user.name != null && user.name != "") {
      userInformation['name'] = user.name;
    }

    await userCollection.doc(user.uid).update(userInformation);
  }

  @override
  Future<void> googleAuth() async {
    final userCollection = fireStore.collection("users");

    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      final GoogleSignInAuthentication googleAuth =
          await account!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final information = (await auth.signInWithCredential(credential)).user;

      getCreateCurrentUser(UserEntity(
        name: information!.displayName,
        email: information.email,
        status: "",
        profileUrl: information.photoURL,
      ));
    } catch (_) {}
  }

  @override
  Future<bool> isSignIn() async {
    return auth.currentUser?.uid != null;
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
  }
}
