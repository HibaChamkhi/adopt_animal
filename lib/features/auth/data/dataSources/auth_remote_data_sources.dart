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

  Future<UserEntity> getCurrentUser();

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
    // firebase_auth (pigeon PigeonUserDetails cast bug) can throw a type-cast
    // error *after* sign-in actually succeeds. Only real FirebaseAuthExceptions
    // (wrong password, user-not-found) should surface as failures.
    try {
      await auth.signInWithEmailAndPassword(
          email: user.email!, password: user.password!);
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      // pigeon cast bug — sign-in likely succeeded; fall through
    }

    // Back-fill a missing profile document so older accounts (Auth user exists
    // but no users/{uid} doc) self-heal on next login.
    if (auth.currentUser != null) {
      await getCreateCurrentUser(user);
    }
  }

  @override
  Future<void> signUp(UserEntity user) async {
    // Do NOT chain the Firestore write with .then(): the pigeon cast bug makes
    // createUserWithEmailAndPassword "throw" even though the Auth account was
    // created, which skips the callback and leaves the user with no profile
    // document. Instead, swallow the non-auth cast error and write explicitly.
    try {
      await auth.createUserWithEmailAndPassword(
          email: user.email!, password: user.password!);
    } on FirebaseAuthException {
      rethrow; // real auth failure (email-already-in-use, weak-password, etc.)
    } catch (_) {
      // pigeon cast bug — the account may still have been created; fall through
    }

    if (auth.currentUser != null) {
      await getCreateCurrentUser(user);
    }
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

    // Awaited throughout so callers actually block on the write completing.
    final userDoc = await userCollection.doc(uid).get();

    if (!userDoc.exists) {
      final newUser = UserModel(
        email: user.email,
        uid: uid,
        status: user.status,
        profileUrl: user.profileUrl,
        name: user.name,
        role: user.role ?? 'adopter',
        phone: user.phone,
        city: user.city,
        bio: user.bio,
      ).toDocument();

      await userCollection.doc(uid).set(newUser);
    }
  }

  @override
  Future<String> getCurrentUId() async => auth.currentUser!.uid;

  @override
  Future<UserEntity> getCurrentUser() async {
    final uid = await getCurrentUId();
    final doc = await fireStore.collection("users").doc(uid).get();
    if (doc.exists) {
      return UserModel.fromSnapshot(doc);
    }
    return const UserEntity();
  }

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
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      final GoogleSignInAuthentication googleAuth =
          await account!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final information = (await auth.signInWithCredential(credential)).user;

      await getCreateCurrentUser(UserEntity(
        name: information!.displayName,
        email: information.email,
        status: "",
        profileUrl: information.photoURL,
        role: "adopter",
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
