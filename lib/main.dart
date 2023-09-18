import 'package:cadcep/pages/home_page.dart';
import 'package:cadcep/pages/lista_enderecos.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de ceps',
      theme: ThemeData(
            primarySwatch: Colors.orange,
      ),
      home:  ListaEnderecos(),
    );
  }
}
