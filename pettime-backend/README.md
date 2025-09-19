# PETTIME - Sistema de Agendamento de Banho e Tosa

PETTIME é um sistema desenvolvido em Node.js com Express, que permite o agendamento de serviços de banho e tosa para pets. Este projeto utiliza a arquitetura MVC (Model-View-Controller) e integra diversas tecnologias para garantir uma experiência robusta e segura.

## Tecnologias Utilizadas

- **Node.js**: Ambiente de execução para JavaScript no servidor.
- **Express**: Framework para construção de APIs e aplicações web.
- **Sequelize**: ORM para facilitar a interação com o banco de dados.
- **Dotenv**: Para gerenciar variáveis de ambiente.
- **JWT (JSON Web Token)**: Para autenticação segura de usuários.
- **bcryptjs**: Para hash e verificação de senhas.
- **Nodemon**: Para reiniciar automaticamente o servidor durante o desenvolvimento.
- **CORS**: Para permitir requisições de diferentes origens.

## Estrutura do Projeto

```
PETTIME
├── src
│   ├── config
│   │   ├── database.js
│   │   └── dotenv.js
│   ├── controllers
│   │   ├── agendamentoController.js
│   │   ├── authController.js
│   │   ├── petController.js
│   │   ├── servicoController.js
│   │   └── usuarioController.js
│   ├── middlewares
│   │   ├── authMiddleware.js
│   │   └── errorHandler.js
│   ├── models
│   │   ├── Agendamento.js
│   │   ├── Pet.js
│   │   ├── Servico.js
│   │   └── Usuario.js
│   ├── routes
│   │   ├── agendamentoRoutes.js
│   │   ├── authRoutes.js
│   │   ├── petRoutes.js
│   │   ├── servicoRoutes.js
│   │   └── usuarioRoutes.js
│   ├── services
│   │   ├── agendamentoService.js
│   │   ├── authService.js
│   │   ├── petService.js
│   │   ├── servicoService.js
│   │   └── usuarioService.js
│   ├── utils
│   │   ├── jwt.js
│   │   └── password.js
│   ├── app.js
│   └── server.js
├── .env
├── .gitignore
├── package.json
├── README.md
└── sequelize.config.js
```

## Como Executar o Projeto

1. Clone o repositório:
   ```
   git clone <URL_DO_REPOSITORIO>
   cd PETTIME
   ```

2. Instale as dependências:
   ```
   npm install
   ```

3. Crie um arquivo `.env` na raiz do projeto e configure as variáveis de ambiente necessárias.

4. Inicie o servidor em modo de desenvolvimento:
   ```
   npm run start:dev
   ```

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## Licença

Este projeto está licenciado sob a MIT License. Veja o arquivo LICENSE para mais detalhes.