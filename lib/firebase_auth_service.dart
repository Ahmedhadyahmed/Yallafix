import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  factory UserModel.fromFirebaseUser(User firebaseUser, String name, String username) {
    return UserModel(
      uid: firebaseUser.uid,
      name: name,
      username: username,
      email: firebaseUser.email ?? '',
      createdAt: DateTime.now(),
    );
  }
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Check if username already exists
      final usernameExists = await _checkUsernameExists(username);
      if (usernameExists) {
        throw Exception('Username already exists');
      }

      // Create user with Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = result.user;
      if (firebaseUser != null) {
        // Create user document in Firestore
        final userModel = UserModel.fromFirebaseUser(firebaseUser, name, username);
        await _createUserDocument(userModel);

        // Update display name
        await firebaseUser.updateDisplayName(name);

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      String email = emailOrUsername;

      // If the input doesn't contain @, treat it as username and get email
      if (!emailOrUsername.contains('@')) {
        email = await _getEmailFromUsername(emailOrUsername);
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = result.user;
      if (firebaseUser != null) {
        return await _getUserDocument(firebaseUser.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user document from Firestore
  Future<UserModel?> _getUserDocument(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  // Check if username already exists
  Future<bool> _checkUsernameExists(String username) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  // Get email from username
  Future<String> _getEmailFromUsername(String username) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      final userData = result.docs.first.data() as Map<String, dynamic>;
      return userData['email'];
    }
    throw Exception('Username not found');
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    final User? firebaseUser = currentUser;
    if (firebaseUser != null) {
      return await _getUserDocument(firebaseUser.uid);
    }
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? username,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (name != null) {
        updateData['name'] = name;
        await currentUser?.updateDisplayName(name);
      }

      if (username != null) {
        // Check if new username already exists
        final usernameExists = await _checkUsernameExists(username);
        if (usernameExists) {
          throw Exception('Username already exists');
        }
        updateData['username'] = username;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final User? user = currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete Firebase Auth user
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Reload current user
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }
}