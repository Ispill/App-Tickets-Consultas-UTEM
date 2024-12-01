import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'category_screen.dart';
import 'filter_tickets_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut(); // Cerrar sesión de Firebase
      await _googleSignIn.disconnect(); // Desconectar cuenta de Google
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false, // Elimina todas las rutas previas
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Página de inicio',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 112, 107),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user?.photoURL != null) ...[
              CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const CircleAvatar(
                radius: 80,
                child: Icon(
                  Icons.person,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'Bienvenido administrativo ${user?.displayName ?? 'Usuario'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FilterTicketsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 110, 105),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ir a la lista de Tickets'),
            ),
          ],
        ),
      ),
    );
  }
}
