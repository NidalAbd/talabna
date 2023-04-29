// import 'dart:convert';
//
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
//
// import '../models/user.dart';
// import '../repositories/authentication_repository.dart';
//
// class AuthenticationService {
//   final AuthenticationRepository _authenticationRepository;
//   final String _googleScope = 'email https://www.googleapis.com/auth/contacts.readonly';
//
//   AuthenticationService(this._authenticationRepository);
//
//   Future<String> loginWithEmailAndPassword(String email, String password) async {
//     try {
//       final accessToken = await _authenticationRepository.login(
//           email: email, password: password, authProvider: 'email');
//       return accessToken;
//     } catch (error) {
//       return '';
//     }
//   }
//
//   Future<String> registerWithEmailAndPassword(
//       String name, String email, String password) async {
//     try {
//       final accessToken = await _authenticationRepository.register(
//           email: email, name: name, password: password, authProvider: 'email');
//       return accessToken;
//     } catch (error) {
//       return '';
//     }
//   }
//
//   Future<String?> loginWithGoogle() async {
//     try {
//       final googleSignIn = GoogleSignIn(
//         scopes: [_googleScope],
//       );
//       final googleUser = await googleSignIn.signIn();
//       if (googleUser != null) {
//         final googleAuth = await googleUser.authentication;
//         final accessToken = googleAuth.accessToken;
//         final profileResponse = await http.get(
//           Uri.parse(
//               'https://www.googleapis.com/userinfo/v2/me?fields=name,email,picture&access_token=$accessToken'),
//         );
//         return accessToken;
//       } else {
//         return '';
//       }
//     } catch (error) {
//       print(error);
//       return '';
//     }
//   }
//
//   Future<String> loginWithFacebook() async {
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();
//
//       if (result.status == LoginStatus.success) {
//         final AccessToken accessToken = result.accessToken!;
//         final profileResponse = await http.get(
//           Uri.parse(
//               'https://graph.facebook.com/v12.0/me?fields=name,email,picture&access_token=${accessToken.token}'),
//         );
//         final profileData = jsonDecode(profileResponse.body);
//         return accessToken.token;
//       } else {
//         return '';
//       }
//     } catch (error) {
//       print(error);
//       return '';
//     }
//   }
// }
