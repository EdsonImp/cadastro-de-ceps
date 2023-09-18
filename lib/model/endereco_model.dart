class Endereco {
  String? logradouro;
  int? cep;
  String? bairro;
  String? uf;
  String? cidade;

  Endereco(this.logradouro, this.cep, this.bairro, this.uf, this.cidade);

  @override
  String toString() {
    return 'Logradouro : $logradouro, \nCEP: $cep,\nBairro: $bairro,\nUF: $uf,\nCidade: $cidade';
  }
}