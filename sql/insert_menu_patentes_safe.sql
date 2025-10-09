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

-- Contar registros inseridos
SELECT 'MENUS INSERIDOS: ' AS TIPO, COUNT(*) AS TOTAL FROM SZC990;
SELECT 'PATENTES INSERIDAS: ' AS TIPO, COUNT(*) AS TOTAL FROM SZB990;
SELECT 'RELACIONAMENTOS INSERIDOS: ' AS TIPO, COUNT(*) AS TOTAL FROM SZD990;

-- Verificar Menus
SELECT ZC_ID, ZC_MENU, ZC_DESC, ZC_ROTA 
FROM SZC990 
ORDER BY ZC_ID;

-- Verificar Patentes
SELECT ZB_ID, ZB_NOME, ZB_DESC 
FROM SZB990 
ORDER BY ZB_ID;

-- Verificar Relacionamentos Simplificados
-- Primeiro teste: ver os dados brutos
SELECT * FROM SZD990;
SELECT * FROM SZB990 LIMIT 3;
SELECT * FROM SZC990 LIMIT 3;

-- Query com conversão INTEGER limpa
SELECT 
    P.ZB_NOME AS PATENTE,
    CASE 
        WHEN R.ZD_MENU::integer = 999999 THEN 'ACESSO TOTAL'
        ELSE M.ZC_MENU 
    END AS ACESSO
FROM SZD990 R
INNER JOIN SZB990 P ON P.ZB_ID::integer = R.ZD_PATENTE::integer
LEFT JOIN SZC990 M ON M.ZC_ID::integer = R.ZD_MENU::integer 
    AND R.ZD_MENU::integer != 999999
ORDER BY P.ZB_NOME;