# ERP-ICS-BACK

Este repositório contém o backend do sistema ERP ICS.

## Estrutura
- `contabilidade/` — Fontes de contabilidade
- `smartview/` — Objetos de Negócios
- `src/` — Código-fonte principal
	- `services/` — Serviços do sistema
	- `util/` — Utilitários
	- `web/` — Interface web

## Principais arquivos
- `.gitignore` — Regras para ignorar arquivos e pastas
- `LICENSE` — Licença do projeto
- `README.md` — Este arquivo de documentação

## Como contribuir
1. Crie uma branch a partir de `desenv`.
2. Faça suas alterações e commits.
3. Envie um pull request para a branch `desenv`.

## Requisitos
- Protheus/TOTVS
- ADVPL

## Tabelas necessárias no banco de dados
O serviço de patentes e menus (`PatenteService`) espera que as seguintes tabelas/views existam e contenham os campos listados abaixo. As consultas no serviço filtram por `D_E_L_E_T_ = ' '` (registros ativos) e usam alguns campos como chave/relacionamento entre tabelas.

1) Tabela: SZE990 (patentes por usuário)
	- ZE_USR      : Código do usuário (ex: '000000')
	- ZE_PATENTE  : Código da patente/permissão atribuída ao usuário (ex: '103', '104' ou '101' para full access)
	- D_E_L_E_T_  : Flag de exclusão lógica (usar ' ' para ativo)

	Exemplo de verificação usada pelo serviço:
	SELECT ZE_PATENTE FROM SZE990 D WHERE D_E_L_E_T_ = ' ' AND D.ZE_USR = '000000'

2) Tabela: SZB990 (definição das patentes)
	- ZB_ID or ZB_COD : Identificador da patente (usado em joins) — preencha conforme seu ambiente (o código do serviço pode referir ZB_ID ou ZB_COD)
	- ZB_NOME     : Nome/código da patente
	- ZB_DESC     : Descrição da patente
	- ZB_MSBLQL   : Flag de bloqueio/visibilidade (usado em checagem de acesso)
	- D_E_L_E_T_  : Flag de exclusão lógica

	Exemplo de consulta retornada pelo serviço (lista de patentes):
	SELECT ZB_ID AS ID_CODIGO, ZB_NOME AS NOME, ZB_DESC AS DESCRICAO FROM SZB990 WHERE D_E_L_E_T_ = ' ' ORDER BY ZB_ID

3) Tabela: SZD990 (mapeamento patente -> menus)
	- ZD_PATENTE  : Código da patente (relaciona-se com SZB)
	- ZD_MENU     : Identificador do menu (ARMAZENA o ZC_ID da tabela de menus)
	- ZD_DESC     : Descrição/observação (opcional)
	- ZD_ACESSO   : '1' se há acesso, outro valor caso contrário
	- D_E_L_E_T_  : Flag de exclusão lógica

	Observação: o serviço usa ZD_MENU para montar a lista de ZC_ID que serão consultados em `SZC990`.

	Exemplo:
	SELECT ZD_PATENTE, ZD_MENU, ZD_DESC FROM SZD990 WHERE D_E_L_E_T_ = ' ' AND ZD_PATENTE IN ('103','104') ORDER BY ZD_MENU

4) Tabela: SZC990 (cadastro de menus / rotas)
	- ZC_ID       : Identificador único do menu (chave primária) — corresponde a ZD_MENU nas permissões
	- ZC_MENU     : Código/label do menu (ex: 'Home', 'Orçamentos')
	- ZC_DESC or ZC_DESCRI : Descrição do menu (o código usa `ZC_DESC` e em alguns lugares `ZC_DESCRI` — preencha conforme sua base)
	- ZC_ROTA     : Rota/URL associada (ex: '/home')
	- D_E_L_E_T_  : Flag de exclusão lógica

	Exemplo de consulta usada para obter rotas:
	SELECT ZC_MENU, ZC_ROTA, ZC_DESC FROM SZC990 WHERE D_E_L_E_T_ = ' ' AND ZC_ID IN ('000007','000008')

Notas importantes
- O serviço considera o usuário administrador quando: FWIsAdmin() retorna verdadeiro ou o usuário possui a patente 101 (ZE_PATENTE = '101'). Nesse caso `all_menus` retorna true e são listados todos os registros ativos da tabela `SZC990`.
- As consultas montam listas IN com os valores vindos de `SZE990` / `SZD990` — garanta que os campos usados como chaves (ZD_MENU -> ZC_ID, ZD_PATENTE -> ZB_ID/COD) tenham o formato esperado (strings com padding se aplicável) e que os valores existam em `SZC990`.
- Mantenha `D_E_L_E_T_ = ' '` nos registros ativos para que as queries do serviço os incluam.

Se quiser, eu posso gerar exemplos de INSERTs para popular essas tabelas de teste com base nos dados de exemplo que você já usou.


