import 'package:cadcep/model/endereco_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController cepController = TextEditingController();
  var endereco;
  List<Endereco> listaEnderecos = [];
  String erro = '';


  Future<http.Response> getAllEndereco() async{
    var url = Uri.parse("https://parseapi.back4app.com/classes/endereco");
    var response = await http.get(url);
    if(response.statusCode == 200){
      return jsonDecode(utf8.decode(response.bodyBytes));
    }else{ throw Exception("Erro ao carrega dados do servidor");
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

  Future<void> consultarCEP(String cep) async {
    final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200)  {
      Map<String, dynamic> data =  json.decode(response.body);
      if (data.containsKey('erro')) {
        setState(() {
          erro = 'CEP não encontrado';

        });

      } else {
        setState(() {
          erro = '';
          endereco = Endereco(data['logradouro'], int.parse(cepController.text), data['bairro'], data['uf'], data['localidade']);

        });

      }
    } else {
      throw Exception('Falha ao carregar dados');
    }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CEP', style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              if (endereco != null)Card(
                color: Colors.orange.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        endereco.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(onPressed: salvaEndereco, icon: Icon(Icons.add_circle))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}