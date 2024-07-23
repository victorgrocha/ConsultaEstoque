# Consulta Estoque

Consulta Estoque é um aplicativo para dispositivos Android desenvolvido em Flutter, com backend em Delphi e banco de dados Firebird. Este aplicativo é projetado para clientes que utilizam nosso sistema ERP desenvolvido em Delphi, como mercados, mercearias, lojas de artigos em geral e comércios que possuem um grande volume de produtos diversos.

## Funcionalidades

- Consulta de Produtos: O usuário pode consultar produtos inserindo o código do produto ou lendo um código de barras. A consulta é feita via API REST, retornando os detalhes do produto.
  
- Alteração de Produtos: O usuário pode alterar o preço e a quantidade em estoque de um produto e enviar uma requisição PUT para o servidor.
  
- Cadastro de Novos Produtos: É possível cadastrar um novo produto inserindo o código de um produto similar já existente no sistema, criando um novo código, descrição, quantidade e preço, 
  e enviando uma requisição POST ao servidor.

 ## Como Funciona

1- Configuração Inicial: O usuário deve estar conectado na mesma rede do servidor do sistema ERP feito em Delphi. Na primeira utilização, será necessário informar o IP do servidor.

2- Consulta de Produtos: Após configurar o IP do servidor, o usuário pode consultar produtos facilmente através do aplicativo.

3- Alteração de Informações: Com o aplicativo, é possível alterar informações de produtos diretamente do celular, sem a necessidade de acessar um computador.

## Tecnologias Utilizadas

- Frontend: Flutter
- Backend: Delphi
- Banco de Dados: Firebird
- Comunicação: API REST
- IDE: VSCode

## Público-Alvo

O aplicativo foi pensado para clientes usuários do nosso sistema em Delphi, principalmente:

- Mercados
- Mercearias
- Lojas de artigos em geral
- Comércios com um grande volume de produtos diversos

### Benefícios
- Praticidade: Facilita a consulta e alteração de informações de produtos diretamente pelo celular.
- Agilidade: Não é necessário se deslocar até um computador para realizar as alterações.
- Eficiência: Simplifica o processo de gestão de estoque, tornando-o mais rápido e eficiente.

### Como Contribuir
Contribuições são bem-vindas! Se você deseja colaborar com o projeto, sinta-se à vontade para abrir um issue ou enviar um pull request.

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo LICENSE para mais detalhes.
