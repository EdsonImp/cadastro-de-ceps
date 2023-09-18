import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/endereco_model.dart';

class ListaEnderecos extends StatefulWidget {
  const ListaEnderecos({super.key});

  @override
  State<ListaEnderecos> createState() => _ListaEnderecosState();
}

class _ListaEnderecosState extends State<ListaEnderecos> {
  @override
  List<dynamic> enderecos = [];

  var endereco;
  String erro = '';
  final TextEditingController cepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarEnderecos();
  }
  void validarCEP(String cep) {
    if (cep.length != 8 || !RegExp(r'^[0-9]+$').hasMatch(cep)) {
      setState(() {
        erro = 'CEP inválido';
      });
    } else {
      setState(() {
        erro = '';
      });
      consultarCEP(cep);
    }
  }
  Future<void> consultarCEP(String cep) async {
    final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('erro')) {
        setState(() {
          erro = 'CEP não encontrado';

        });

      } else  {
         setState(() {
          erro = '';
          endereco = Endereco(data['logradouro'], int.parse(cepController.text), data['bairro'], data['uf'], data['localidade']);
          //endereco = 'Endereço: ${data['logradouro']}, Bairro: ${data['bairro']}, Cidade:  ${data['localidade']} - ${data['uf']}';
        });


      }
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
  bool cepExisteNaLista(int cepProcurado, List<dynamic> listaDeEnderecos) {
    for (var endereco in listaDeEnderecos) {
      if (endereco['cep'] == cepProcurado) {
        return true;
      }
    }
    return false;
  }
  void _carregarEnderecos() async {
    final response = await http.get(
      Uri.parse('https://parseapi.back4app.com/classes/endereco'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Parse-Application-Id': 'KTrYFVO3Ur8j0zyNhfNJI7zLDuJLhtGHJpZVvZYB',
        'X-Parse-REST-API-Key': 'n8NOOta9bmlDUoJ1LGQjp17R9F35TEneWiZoGVHS'
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        enderecos = json.decode(response.body)['results'];
      });
    } else {
      throw Exception('Falha ao carregar os endereços');
    }
  }
  Future<http.Response> salvaEndereco() async{
    return await http.post(
        Uri.parse('https://parseapi.back4app.com/classes/endereco'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Parse-Application-Id': 'KTrYFVO3Ur8j0zyNhfNJI7zLDuJLhtGHJpZVvZYB',
          'X-Parse-REST-API-Key': 'n8NOOta9bmlDUoJ1LGQjp17R9F35TEneWiZoGVHS'
        },
        body: jsonEncode(<String, dynamic>{
          'logradouro': endereco.logradouro,
          'cep': endereco.cep,
          'bairro': endereco.bairro,
          'uf': endereco.uf,
          'cidade': endereco.cidade,

        })

    );

  }


  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            showDialog(context: context, builder: (BuildContext bc){
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: cepController,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        decoration: InputDecoration(
                          labelText: 'CEP',
                          hintText: 'Informe o CEP (apenas números)',
                          errorText: erro,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          validarCEP(cepController.text);
                        },
                        child: const Text('Consultar'),
                      ),
                      const SizedBox(height: 16.0),
                      if (endereco != null)
                        Card(
                        color: Colors.orange.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                               Text(
                                endereco.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(onPressed: (){
                                var exist = cepExisteNaLista(int.parse(cepController.text),enderecos);
                                 if (exist == false){print("o cep nao foi cadastrado ainda");}  else print("CEP já cadastrado");
                              }, icon: const Icon(Icons.add_circle))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              );
            }
            );

          }, icon: Icon(Icons.add))
        ],
        title: Text("Minha lista de endereços"),
        centerTitle: true,
      ),
      body:enderecos.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      ) :  ListView.builder(
        itemCount: enderecos.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text('${enderecos[index]['logradouro']}\nCEP:  ${enderecos[index]['cep'].toString()}\nCidade: ${enderecos[index]['cidade']}-${enderecos[index]['uf']}'),

            ),
          );
        },
      ),
    );
  }
}
