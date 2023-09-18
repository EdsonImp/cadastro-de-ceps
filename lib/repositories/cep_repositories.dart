import 'package:http/http.dart' as http;


class CepRepositories{

  Future<http.Response> deleteCep(String id) async{
    var url = 'https://parseapi.back4app.com/classes/endereco/$id';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Parse-Application-Id': 'KTrYFVO3Ur8j0zyNhfNJI7zLDuJLhtGHJpZVvZYB',
        'X-Parse-REST-API-Key': 'n8NOOta9bmlDUoJ1LGQjp17R9F35TEneWiZoGVHS'
      },
    );
    print (response.body);
    return response;
  }

}