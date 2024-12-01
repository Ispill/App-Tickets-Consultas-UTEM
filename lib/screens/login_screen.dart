import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        if (userCredential.user?.email?.endsWith('@utem.cl') ?? false) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          await _auth.signOut();
          await _googleSignIn.disconnect();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, usa un correo @utem.cl')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inicio de Sesión',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 112, 107),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo grande
            Image.asset(
              'assets/utem-logo.png',
              height: 300, // Ajusta el tamaño según tus necesidades
              width: 300,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => signInWithGoogle(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 110, 105),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/google-logo.png', // Icono de Google
                    height: 24, // Ajusta el tamaño según tus necesidades
                    width: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text('Iniciar sesión con Google'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
