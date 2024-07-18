import 'package:consulta_estoque_netsul_informatica/api_buscaProdutos/buscaProdutos_page.dart';
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

class AuthProvider with ChangeNotifier {
  String? _username;
  String? _password;
  String? _errorMessage;

  String? get username => _username;
  String? get password => _password;
  String? get errorMessage => _errorMessage;

  void setCredentials(String username, String password) {
    _username = username;
    _password = password;
    _errorMessage =
        null; // Limpar a mensagem de erro ao definir novas credenciais
    notifyListeners();
  }

  bool get isAuthenticated {
    // Adicione aqui a lógica para verificar as credenciais
    return _username == 'admin' && _password == 'admin';
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ConsultaEstoque',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final authProvider = context.read<AuthProvider>();
                    authProvider.setCredentials('admin', 'admin');

                    if (authProvider.isAuthenticated) {
                      authProvider
                          .clearError(); // Limpar a mensagem de erro ao autenticar com sucesso
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchProductPage()),
                      );
                    } else {
                      // Mostrar a mensagem de erro
                      authProvider
                          .setErrorMessage('Usuário ou senha inválidos');
                    }
                  },
                  child: Text('Entrar'),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Adicione aqui a navegação para a tela de cadastro
                  },
                  child: Text(
                    'Criar uma conta',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (context.watch<AuthProvider>().errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      context.watch<AuthProvider>().errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
