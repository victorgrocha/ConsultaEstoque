// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IPAddressPage extends StatefulWidget {
  @override
  _IPAddressPageState createState() => _IPAddressPageState();
}

class _IPAddressPageState extends State<IPAddressPage> {
  TextEditingController _ipController = TextEditingController();
  late String _ipAddress; // Defina como "late"

  _IPAddressPageState() {
    _ipAddress = ''; // Inicialize no construtor
  }

  @override
  void initState() {
    super.initState();
    _loadIPAddress();
  }

  Future<void> _loadIPAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIPAddress = prefs.getString('ipAddress');
    setState(() {
      if (savedIPAddress != null) {
        _ipAddress = savedIPAddress;
        _ipController.text = _ipAddress; // Atualiza o campo de texto
      } else {
        _ipAddress =
            '192.168.15.47:8090'; //  Define um IP padrão se nenhum estiver salvo
      }
    });
  }

  Future<void> _saveIPAddress() async {
    final ipAddress = _ipController.text;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', ipAddress);
    setState(() {
      _ipAddress = ipAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB388FF),
        title: Text('Configurar IP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('IP Salvo: $_ipAddress'), // Exibe o IP salvo ou o padrão
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Informe o IP da rede',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                await _saveIPAddress();
                Navigator.pop(context, _ipController.text);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
