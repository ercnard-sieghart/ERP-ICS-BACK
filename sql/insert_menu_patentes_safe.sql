-- ==================================================
-- SCRIPT DE INSERÇÃO DE MENUS E PATENTES (VERSÃO SEGURA)
-- Sistema: ERP ICS
-- Data: 09/10/2025
-- ==================================================

-- ==================================================
-- LIMPEZA TOTAL DAS TABELAS (EXECUTAR PRIMEIRO)
-- ==================================================

-- Limpar tabelas completamente (ordem importante: primeiro os relacionamentos)
TRUNCATE TABLE SZD990 RESTART IDENTITY CASCADE;
TRUNCATE TABLE SZB990 RESTART IDENTITY CASCADE;  
TRUNCATE TABLE SZC990 RESTART IDENTITY CASCADE;

-- Verificar se tabelas estão vazias
SELECT COUNT(*) AS MENUS_TOTAL FROM SZC990;
SELECT COUNT(*) AS PATENTES_TOTAL FROM SZB990;
SELECT COUNT(*) AS RELACIONAMENTOS_TOTAL FROM SZD990;

-- ===========================
-- TABELA SZC - MENUS
-- ===========================

-- MENU 1: HOME/DASHBOARD
INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000001', 'Home', 'Página inicial do sistema', '/home', ' ', 1);

INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000002', 'Dashboard', 'Painel Dashboard', '/dashboard', ' ', 2);

-- MENU 2: COMPRAS
INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000003', 'SC de Compras', 'Gerenciar solicitações', '/compras/solicitacao', ' ', 3);

-- MENU 3: CONSULTAS  
INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000004', 'Consultas', 'Menu principal de consultas', '/consultas', ' ', 4);

INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000005', 'Extrato Bancário', 'Consulta de extrato bancário', '/consultas/extrato-bancario', ' ', 5);

INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000006', 'Relatórios', 'Consulta de relatórios', '/consultas/consulta-relatorio', ' ', 6);

-- MENU 4: ORÇAMENTOS
INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000007', 'Orçamentos', 'Gerenciamento de orçamentos', '/orcamentos', ' ', 7);

-- MENU 5: DETALHES
INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000008', 'Detalhe Item', 'Visualização detalhada de itens', '/detalhe-item', ' ', 8),
	INSERT INTO SZC990 (ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA, D_E_L_E_T_, R_E_C_N_O_) 
	VALUES ('000009', 'Patentes', 'Administração de patentes', '/admin/patentes', ' ', 9);

-- ===========================
-- TABELA SZB - PATENTES
-- ===========================

-- PATENTE 1: ADMINISTRADOR
INSERT INTO SZB990 (ZB_ID, ZB_NOME, ZB_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000001', 'ADMINISTRADOR', 'Acesso total ao sistema', ' ', 9);

-- PATENTE 2: GERENTE
INSERT INTO SZB990 (ZB_ID, ZB_NOME, ZB_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000002', 'GERENTE', 'Acesso gerencial', ' ', 10);

-- PATENTE 3: SUPERVISOR
INSERT INTO SZB990 (ZB_ID, ZB_NOME, ZB_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000003', 'SUPERVISOR', 'Supervisão de processos', ' ', 11);

-- PATENTE 4: ANALISTA
INSERT INTO SZB990 (ZB_ID, ZB_NOME, ZB_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000004', 'ANALISTA', 'Análise e consultas', ' ', 12);

-- PATENTE 5: OPERADOR
INSERT INTO SZB990 (ZB_ID, ZB_NOME, ZB_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000005', 'OPERADOR', 'Operações básicas', ' ', 13);

-- PATENTE 6: CONSULTOR
INSERT INTO SZB990 (ZB_ID, ZB_NOME, ZB_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000006', 'CONSULTOR', 'Apenas consultas', ' ', 14);

-- PATENTE 7: VISITANTE
INSERT INTO SZB990 (ZB_ID, ZB_NOME, ZB_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000007', 'VISITANTE', 'Acesso limitado', ' ', 15);

-- ===========================
-- TABELA SZD - PATENTE_MENUS (RELACIONAMENTOS SIMPLIFICADOS)
-- ===========================

-- ADMINISTRADOR - Acesso total
INSERT INTO SZD990 (ZD_ID, ZD_PATENTE, ZD_MENU, ZD_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000001', '000001', '999999', 'Admin total', ' ', 16);

-- GERENTE - Acesso gerencial
INSERT INTO SZD990 (ZD_ID, ZD_PATENTE, ZD_MENU, ZD_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000002', '000002', '000004', 'Gerente Consultas', ' ', 17);

-- ANALISTA - Apenas consultas
INSERT INTO SZD990 (ZD_ID, ZD_PATENTE, ZD_MENU, ZD_DESC, D_E_L_E_T_, R_E_C_N_O_) 
VALUES ('000003', '000004', '000004', 'Analista Consultas', ' ', 18);

-- ==================================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS (EXECUTAR APÓS OS INSERTS!)
-- ==================================================

-- TABELA SZB - PATENTES_USUARIOS
SELECT * FROM 	SZE990

-- TABELA SZB - PATENTES
SELECT * FROM 	SZB990

-- TABELA SZD - PATENTE_MENUS 
SELECT * FROM  SZD990 

-- TABELA SZC - MENUS
SELECT * FROM  	SZC990 


-- VERIFICA SE O CÓD DO USUARIO POSSUI ALGUMA PATENTE
SELECT ZE_PATENTE FROM SZE990 D WHERE  D_E_L_E_T_ = ' ' AND D.ZE_USR = '000000'

-- SE FOR ADMINISTRATOR OU POSSUIR A PATENTE 101 RETORNAR TODOS OS MENUS
localhost:8181/rest/patentes/menus
{"success":true,"all_menus":true,"menus":[{"menu":"Home","descricao":"P�gina inicial do sistema","rota":"/home"},{"menu":"Dashboard","descricao":"Painel Dashboard","rota":"/dashboard"},{"menu":"SC de Compras","descricao":"Gerenciar solicita��es","rota":"/compras/solicitacao"},{"menu":"Consultas","descricao":"Menu principal de consultas","rota":"/consultas"},{"menu":"Extrato Banc�rio","descricao":"Consulta de extrato banc�rio","rota":"/consultas/extrato-bancario"},{"menu":"Relat�rios","descricao":"Consulta de relat�rios","rota":"/consultas/consulta-relatorio"},{"menu":"Or�amentos","descricao":"Gerenciamento de or�amentos","rota":"/orcamentos"},{"menu":"Detalhe Item","descricao":"Visualiza��o detalhada de itens","rota":"/detalhe-item"},{"menu":"Patentes","descricao":"Administra��o de patentes","rota":"/admin/patentes"}]}

-- SE NÃO FOR ADM/101 VERIFICA AS PATENTES DO USUARIO

SELECT ZC_MENU,ZC_ROTA,ZC_DESC FROM SZC990 WHERE  D_E_L_E_T_ = ' ' AND ZC_ID IN ('000007','000008') 