// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, avoid_print, unused_element, prefer_final_fields, library_private_types_in_public_api, use_key_in_widget_constructors, unused_field, file_names

import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:connectivity/connectivity.dart';
import 'package:consulta_estoque_netsul_informatica/cadastroProdutos/cadastroProdutos_page.dart';
import 'package:consulta_estoque_netsul_informatica/configura%C3%A7%C3%A3oServidor/configuracao_servidor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SearchProductApp());
}

class SearchProductApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busca Produtos',
      home: SearchProductPage(),
    );
  }
}

class Product {
  final String? procod;
  dynamic pronom;
  double? proest;
  double? proval;

  Product({
    this.procod,
    this.pronom,
    this.proest,
    this.proval,
  });

  toJson() {}
}

String postToJsonProduct(Product data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}

class SearchProductPage extends StatefulWidget {
  @override
  _SearchProductPageState createState() => _SearchProductPageState();
}

class _SearchProductPageState extends State<SearchProductPage> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _valueController = TextEditingController();
  Product? _product;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isStockEditing = false;
  bool _isValueEditing = false;
  Product? _editedProduct;
  Product? _originalProduct; // Mantenha o produto original aqui
  String _ipAddress = '';
  bool _clearCodeOnSearch = false;
  bool _clearCode = false;
  FocusNode _searchFieldFocusNode = FocusNode();

  Future<String> _loadIPAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIPAddress = prefs.getString('ipAddress');
    if (savedIPAddress != null) {
      return savedIPAddress;
    } else {
      return '192.168.15.47:8090';
    }
  }

  @override
  void initState() {
    super.initState();
    _editedProduct = Product();
    _loadIPAddress().then((ip) {
      setState(() {
        _ipAddress = ip;
      });
    });
  }

  bool _isValidIPAddress(String ipAddress) {
    final parts = ipAddress.split('.');
    if (parts.length != 4) {
      return false;
    }

    return parts.every((String part) {
      try {
        final int value = int.parse(part);
        return value >= 0 && value <= 255;
      } catch (e) {
        return false;
      }
    });
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
                'Sem conexão com a internet. Verifique sua conexão e tente novamente.'),
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

            _nameController.text = _editedProduct?.pronom;

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
          // Exibir uma mensagem de erro aqui
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
                'Erro ao buscar o produto. Verifique a rede conectada ou IP.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } finally {
      if (_product != null) {
        // Preenche o campo de pesquisa com o código lido apenas se nenhum produto for encontrado
        setState(() {
          _searchController.text;
          _clearCodeOnSearch =
              true; // Adiciona uma flag para limpar o código quando o usuário clicar no campo
        });
      }

      // Verifica se o campo de pesquisa está focado
      if (_searchFieldFocusNode.hasFocus) {
        // Limpa o campo de pesquisa apenas se nenhum produto for encontrado e o campo estiver focado
        setState(() {
          _searchController.text = '';
          _clearCodeOnSearch =
              true; // Adiciona uma flag para limpar o código quando o usuário clicar no campo
        });
      } else {
        // Limpa o campo de quantidade apenas se o campo de pesquisa não estiver focado
        setState(() {
          _stockController.text = _originalProduct!.proest!.toStringAsFixed(2);
        });
      }
    }
  }

  Future<void> _updateEstoque(double novoEstoque) async {
    if (novoEstoque != _product!.proest) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> data = {
        'proest': novoEstoque,
      };

      final jsonData = json.encode(data);

      try {
        final response = await http.put(
          Uri.parse(
              'http://$_ipAddress/api/alteraproduto/' + _product!.procod!),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );

        if (response.statusCode == 200) {
          setState(() {
            _product!.proest = novoEstoque;
            _stockController.text = novoEstoque.toStringAsFixed(2);
          });

          _showSuccessMessage('Quantidade salvo com sucesso');
        } else {
          print('Erro na solicitação PUT: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Erro ao atualizar o QUANTIDADE! Tente novamente.',
              style: TextStyle(color: Colors.white),
            ),
          ));

          // Se ocorreu um erro, reverta o campo de estoque para o valor original
          _stockController.text = _originalProduct!.proest!.toStringAsFixed(2);
        }
      } catch (error) {
        print('Erro durante a solicitação PUT: $error');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao atualizar o QUANTIDADE! Tente novamente.',
            style: TextStyle(color: Colors.white),
          ),
        ));

        // Se ocorreu um erro, reverta o campo de estoque para o valor original
        _stockController.text = _originalProduct!.proest!.toStringAsFixed(2);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateValor(double novoValor) async {
    if (novoValor != _product!.proval) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> data = {
        'proval': novoValor,
      };

      final jsonData = json.encode(data);

      try {
        final response = await http.put(
          Uri.parse(
              'http://$_ipAddress/api/alteraprecoproduto/' + _product!.procod!),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );

        if (response.statusCode == 200) {
          setState(() {
            _product!.proval = novoValor;
            _valueController.text = novoValor.toStringAsFixed(2);
          });

          _showSuccessMessage('Valor salvo com sucesso');
        } else {
          print('Erro na solicitação PUT: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Erro ao atualizar o VALOR. Tente novamente.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );

          // Se ocorreu um erro, reverta o campo de valor para o valor original
          _valueController.text = _originalProduct!.proval!.toStringAsFixed(2);
        }
      } catch (error) {
        print('Erro durante a solicitação PUT: $error');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erro ao atualizar o VALOR. Tente novamente.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ));

        // Se ocorreu um erro, reverta o campo de valor para o valor original
        _valueController.text = _originalProduct!.proval!.toStringAsFixed(2);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // Cor de fundo verde
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode) {
        final scannedCode = result.rawContent;
        final ipAddress = _ipAddress; // Salva o valor atual do IP

        // Limpa o campo de pesquisa
        setState(() {
          _searchController.text = '';
        });

        // Realiza a busca com o código de barras
        await _searchProductWithCustomIP(ipAddress, scannedCode);

        // Verifica se a busca não retornou um produto
        if (_product == null) {
          // Preenche o campo de pesquisa com o código lido apenas se nenhum produto for encontrado
          setState(() {
            _searchController.text = scannedCode;
            _clearCodeOnSearch =
                true; // Adiciona uma flag para limpar o código quando o usuário clicar no campo
          });
        }

        // Verifica se o campo de pesquisa está focado
        if (_searchFieldFocusNode.hasFocus) {
          // Limpa o campo de pesquisa apenas se nenhum produto for encontrado e o campo estiver focado
          setState(() {
            _searchController.text = '';
            _clearCodeOnSearch =
                true; // Adiciona uma flag para limpar o código quando o usuário clicar no campo
          });
        }
      } else {
        // Lide com outros tipos de resultado, se necessário
      }
    } catch (e) {
      // Lide com erros ao escanear o código de barras
      print('Erro ao escanear código de barras: $e');
    }
  }

  String _formatNumberWithComma(String number) {
    return number.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB388FF),
        title: const Text('Busca Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final newIPAddress = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IPAddressPage(),
                ),
              );
              if (newIPAddress != null) {
                setState(() {
                  _ipAddress = newIPAddress;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                focusNode: _searchFieldFocusNode,
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: screenWidth * 0.06),
                  labelText: 'Digite o código do produto',
                ),
                style: TextStyle(fontSize: screenWidth * 0.06),
                keyboardType: TextInputType.number,
                onTap: () {
                  if (_clearCodeOnSearch) {
                    setState(() {
                      _searchController.clear();
                      _clearCodeOnSearch = false;
                    });
                  }
                },
              ),
              SizedBox(height: screenWidth * 0.02),
              ElevatedButton(
                onPressed: () {
                  if (_ipAddress.isNotEmpty) {
                    _searchFieldFocusNode.unfocus();
                    _searchProductWithCustomIP(
                      _ipAddress,
                      _searchController.text,
                    );
                  } else {
                    // Lidere com o caso em que _ipAddress é vazio (por exemplo, exiba um erro).
                  }
                },
                child: Text(
                  'Pesquisar',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              ElevatedButton(
                onPressed: _scanBarcode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt),
                    const SizedBox(width: 8),
                    Text(
                      'Escanear Código de Barras',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _product != null
                      ? Card(
                          color: const Color(0xFFB388FF),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(25.0),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Código: ${_product!.procod}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.030,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.012),
                                _isEditing
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: screenWidth * 0.0100),
                                            child: TextFormField(
                                              controller: _nameController,
                                              onChanged: (value) {
                                                setState(() {
                                                  _editedProduct!.pronom =
                                                      value;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Nome',
                                              ),
                                              style: TextStyle(
                                                  fontSize:
                                                      screenWidth * 0.050),
                                              enabled: false,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: screenWidth * 0.0100),
                                            child: TextFormField(
                                              controller: _stockController,
                                              onChanged: (value) {
                                                double novoEstoque;
                                                try {
                                                  // Substitua pontos por vírgulas antes de converter
                                                  _stockController.value =
                                                      TextEditingValue(
                                                    text: value.replaceAll(
                                                        ',', '.'),
                                                    selection: _stockController
                                                        .selection,
                                                  );
                                                  novoEstoque = double.parse(
                                                      value.replaceAll(
                                                          ',', '.'));
                                                  setState(() {
                                                    _editedProduct!.proest =
                                                        novoEstoque;
                                                  });
                                                } catch (e) {
                                                  print(
                                                      'Erro de conversão: $e');
                                                  return;
                                                }
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Quantidade',
                                              ),
                                              style: TextStyle(
                                                  fontSize:
                                                      screenWidth * 0.050),
                                              enabled: _isStockEditing,
                                              autofocus: _isStockEditing,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: screenWidth * 0.0100),
                                            child: TextFormField(
                                              controller: _valueController,
                                              onChanged: (value) {
                                                double novoValor;
                                                try {
                                                  // Substitua pontos por vírgulas antes de converter
                                                  _valueController.value =
                                                      TextEditingValue(
                                                    text: value.replaceAll(
                                                        ',', '.'),
                                                    selection: _valueController
                                                        .selection,
                                                  );
                                                  novoValor = double.parse(value
                                                      .replaceAll(',', '.'));
                                                  setState(() {
                                                    _editedProduct!.proval =
                                                        novoValor;
                                                  });
                                                } catch (e) {
                                                  print(
                                                      'Erro de conversão: $e');
                                                  return;
                                                }
                                              },
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              decoration: const InputDecoration(
                                                labelText: 'Valor',
                                              ),
                                              style: TextStyle(
                                                  fontSize:
                                                      screenWidth * 0.050),
                                              enabled: _isValueEditing,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nome: ${_product!.pronom}',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Quantidade: ${_formatNumberWithComma(_product!.proest!.toStringAsFixed(2))}',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Valor: ${_formatNumberWithComma(_product!.proval!.toStringAsFixed(2))}',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                SizedBox(height: screenWidth * 0.02),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_isEditing) {
                                            _isEditing = false;
                                            _isStockEditing = false;
                                            _isValueEditing = false;

                                            _editedProduct = Product(
                                              procod: _product!.procod,
                                              pronom: _product!.pronom,
                                              proest: _product!.proest,
                                              proval: _product!.proval,
                                            );
                                            _nameController.text =
                                                _editedProduct!.pronom ?? '';
                                            _stockController.text =
                                                _editedProduct!.proest
                                                        ?.toStringAsFixed(2) ??
                                                    '';
                                            _valueController.text =
                                                _editedProduct!.proval
                                                        ?.toStringAsFixed(2) ??
                                                    '';
                                          } else {
                                            _isEditing = true;
                                            _isStockEditing = true;
                                            _isValueEditing = true;
                                          }
                                        });
                                      },
                                      child: Text(
                                        _isEditing
                                            ? 'Cancelar Alterações'
                                            : 'Alterar',
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.030),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    if (_isStockEditing || _isValueEditing)
                                      ElevatedButton(
                                        onPressed: () async {
                                          final novoEstoque = double.parse(
                                              _stockController.text);
                                          final novoValor = double.parse(
                                              _valueController.text);

                                          await _updateEstoque(novoEstoque);
                                          await _updateValor(novoValor);

                                          await Future.wait([
                                            _updateEstoque(novoEstoque),
                                            _updateValor(novoValor),
                                          ]);
                                          // Atualize as informações no primeiro Card
                                          setState(() {
                                            _product!.proest = novoEstoque;
                                            _product!.proval = novoValor;
                                          });

                                          // Volte ao primeiro Card
                                          setState(() {
                                            _isEditing = false;
                                            _isStockEditing = false;
                                            _isValueEditing = false;
                                          });
                                        },
                                        child: Text(
                                          'Salvar Alterações',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.030,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Text(
                          'Produto não encontrado',
                          style: TextStyle(fontSize: screenWidth * 0.03),
                        ),
              SizedBox(height: screenWidth * 0.02),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TelaCadastroProdutos()),
                  );
                },
                child: Text(
                  'CADASTRAR UM PRODUTO',
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
