import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  // Inicializa o Flutter antes dos serviços assíncronos.
  WidgetsFlutterBinding.ensureInitialized();
  // Conecta o aplicativo ao projeto configurado pelo FlutterFire CLI.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // DevicePreview 3.x: emula o tamanho dos dispositivos via Flutter DevTools.
  runApp(
    DevicePreview(
      builder: (context) => const MuralApp(),
    ),
  );
}

class MuralApp extends StatelessWidget {
  const MuralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mural da Turma',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data == null ? const LoginPage() : const HomePage();
        },
      ),
    );
  }
}
