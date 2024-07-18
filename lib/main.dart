// ignore_for_file: prefer_const_constructors

import 'package:consulta_estoque_netsul_informatica/api_buscaProdutos/buscaProdutos_page.dart';
import 'package:consulta_estoque_netsul_informatica/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Consulta Estoque',
        color: Color(0xFFB388FF),
        home: LoginPage());
  }
}
