
# ERP-ICS-BACK

## Sobre o Back-End da Solução ICS Web

Este repositório contém o back-end da solução ICS Web, responsável por tratar todas as regras de negócio, autenticação de usuários e integração com sistemas externos.

### Principais responsabilidades:

- **Regras de Negócio:**
	- Toda a lógica de validação, cálculos, permissões e fluxos do sistema é centralizada no back-end, garantindo consistência e segurança dos dados.

- **Sistema de Login:**
	- Implementação de webservices para autenticação, geração de tokens de acesso e controle de sessões de usuários.
	- Validação de credenciais e resposta padronizada para integração com o front-end.

- **Integrações:**
	- Comunicação com bancos de dados, sistemas legados e APIs externas.

- **Outras funcionalidades:**
	- Gerenciamento de usuários, permissões, auditoria de operações e tratamento de erros.
	- Estrutura para expansão de novos módulos e serviços conforme necessidade do negócio.

O back-end é desenvolvido em AdvPL, utilizando padrões RESTful para facilitar a integração com o front-end e outros sistemas.
