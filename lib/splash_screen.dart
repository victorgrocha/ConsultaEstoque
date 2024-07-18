// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:async';

import 'package:consulta_estoque_netsul_informatica/api_buscaProdutos/buscaProdutos_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Chama a função após 3 segundos
    Timer(
      Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchProductPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple, // Cor de fundo roxa
      body: Center(
        child: Image.asset(
          "assets/ic_launcher.png", // Substitua pelo caminho da sua imagem de logo
          width: 400, // Ajuste conforme necessário
          height: 400, // Ajuste conforme necessário
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sua tela inicial ou home screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha App Flutter'),
      ),
      body: Center(
        child: Text('Bem-vindo!'),
      ),
    );
  }
}
