// ignore_for_file: unused_field

import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaCadastroProdutos extends StatefulWidget {
  @override
  _TelaCadastroProdutosState createState() => _TelaCadastroProdutosState();
}

class _TelaCadastroProdutosState extends State<TelaCadastroProdutos> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _valueController = TextEditingController();
  TextEditingController _newCodeController = TextEditingController();
  String _ipAddress = '';
  Product? _product;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isStockEditing = false;
  bool _isValueEditing = false;
  Product? _editedProduct;
  Product? _originalProduct;
  bool _clearCodeOnSearch = false;
  bool _clearCode = false;
  FocusNode _searchFieldFocusNode = FocusNode();

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
      } else {
        _ipAddress = '192.168.15.47:8090';
      }
    });
  }

  Future<void> _cadastrarNovoProduto(String ipAddress, String procod) async {
    final String url = 'http://$_ipAddress/api/pegaproduto/$procod';
    final Map<String, dynamic> data = {
      'procod': _newCodeController.text, // Usando o novo código
      'pronom': _nameController.text,
      'proest': double.parse(_stockController.text),
      'proval': double.parse(_valueController.text),
    };

    final jsonData = json.encode(data);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Produto cadastrado com sucesso');
      } else {
        print('Erro na solicitação POST: ${response.statusCode}');
        _showErrorMessage('Erro ao cadastrar o produto. Tente novamente.');
      }
    } catch (error) {
      print('Erro durante a solicitação POST: $error');
      _showErrorMessage('Erro ao cadastrar o produto. Tente novamente.');
    }
  }

  Future<void> _searchProductWithCustomIP(
      String ipAddress, String procod) async {
    setState(() {
      _isLoading = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }

    try {
      final uri = Uri.parse('http://$ipAddress/api/pegaproduto/$procod');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('erro')) {
          setState(() {
            _product = null;
            _isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produto não encontrado, verifique o código.'),
              ),
            );
          });
        } else {
          setState(() {
            _product = Product(
              procod: jsonData['procod'],
              pronom: jsonData['pronom'],
              proest: num.parse(jsonData['proest'].toString()).toDouble(),
              proval: num.parse(jsonData['proval'].toString()).toDouble(),
            );

            _originalProduct = Product(
              procod: jsonData['procod'],
              pronom: jsonData['pronom'],
              proest: num.parse(jsonData['proest'].toString()).toDouble(),
              proval: num.parse(jsonData['proval'].toString()).toDouble(),
            );

            _editedProduct = Product(
              procod: jsonData['procod'],
              pronom: jsonData['pronom'],
              proest: num.parse(jsonData['proest'].toString()).toDouble(),
              proval: num.parse(jsonData['proval'].toString()).toDouble(),
            );

            _nameController.text = _editedProduct!.pronom!;

            _valueController.text = _editedProduct!.proval!.toStringAsFixed(2);
            _isLoading = false;
            _clearCodeOnSearch = false;
            _clearCode = false;
          });
        }
      } else {
        setState(() {
          _product = null;
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ERRO, verifique o código inserido! '),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    } catch (error) {
      print('Erro: $error');

      setState(() {
        _product = null;
        _isLoading = false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erro ao buscar o produto. Verifique a rede conectada ou IP.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      });
    } finally {
      if (_product != null) {
        setState(() {
          _searchController.text;
          _clearCodeOnSearch = true;
        });
      }

      if (_searchFieldFocusNode.hasFocus) {
        setState(() {
          _searchController.text = '';
          _clearCodeOnSearch = true;
        });
      } else {
        setState(() {
          _stockController.text =
              _originalProduct?.proest?.toStringAsFixed(2) ?? '';
        });
      }
    }
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode) {
        final scannedCode = result.rawContent;
        final ipAddress = _ipAddress;

        setState(() {
          _searchController.text = '';
        });

        await _searchProductWithCustomIP(ipAddress, scannedCode);

        if (_product == null) {
          setState(() {
            _searchController.text = scannedCode;
            _clearCodeOnSearch = true;
          });
        }

        if (_searchFieldFocusNode.hasFocus) {
          setState(() {
            _searchController.text = '';
            _clearCodeOnSearch = true;
          });
        }
      } else {
        // Handle other result types if needed
      }
    } catch (e) {
      print('Error scanning barcode: $e');
    }
  }

  void _createNewProduct() {
    setState(() {
      _isEditing = false;
      _clearFields();
    });
  }

  void _clearFields() {
    _searchController.text = '';
    _nameController.text = '';
    _stockController.text = '';
    _valueController.text = '';
    _newCodeController.text = ''; // Limpar o campo do novo código
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB388FF),
        title: const Text('Duplicar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: screenWidth * 0.04),
                  labelText: 'Código de um produto similar',
                ),
                style: TextStyle(fontSize: screenWidth * 0.04),
                enabled: !_isEditing,
              ),
              SizedBox(height: screenWidth * 0.02),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _searchProductWithCustomIP(
                            _ipAddress,
                            _searchController.text,
                          );
                        },
                        child: Text(
                          'Pesquisar Produto',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      ElevatedButton(
                        onPressed: () {
                          _scanBarcode();
                        },
                        child: Text(
                          'Escanear Código de Barras',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      ElevatedButton(
                        onPressed: () {
                          _cadastrarNovoProduto(
                            _ipAddress,
                            _searchController.text,
                          );
                        },
                        child: Text(
                          'Cadastrar Produto',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              TextField(
                controller: _newCodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: screenWidth * 0.04),
                  labelText: 'Novo Código do Produto',
                ),
                style: TextStyle(fontSize: screenWidth * 0.04),
                enabled: !_isEditing,
              ),
              SizedBox(height: screenWidth * 0.02),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: screenWidth * 0.04),
                  labelText: 'Nome do Produto',
                ),
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenWidth * 0.02),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: screenWidth * 0.04),
                  labelText: 'Quantidade',
                ),
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenWidth * 0.02),
              TextField(
                controller: _valueController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: screenWidth * 0.04),
                  labelText: 'Valor',
                ),
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenWidth * 0.02),
              ElevatedButton(
                onPressed: () {
                  _cadastrarNovoProduto(
                    _ipAddress,
                    _newCodeController.text, // Usando o novo código
                  );
                },
                child: Text(
                  'Cadastrar Produto',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String? procod;
  final String? pronom;
  final double? proest;
  final double? proval;

  Product({
    this.procod,
    this.pronom,
    this.proest,
    this.proval,
  });
}
