#Include "protheus.ch"
#Include "totvs.ch"
#Include "TbiConn.ch"
#Include "topconn.ch"

Class PatenteService
    Static Method GetAllPatentes() as json
    Static Method GetAcessosPatente(cPatente) as json
    Static Method GetAllMenus() as json
    Static Method ValidarAcesso(oBody) as json
    Static Method GetRotasUsuario(oBody) as json
EndClass

Method GetAllPatentes() Class PatenteService as json
    Local oJsonResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aPatentes := {}
    Local oPatente := Nil
    
	cQuery := "SELECT "
	cQuery += "    ZB_ID     AS ID_CODIGO, "
	cQuery += "    ZB_NOME   AS NOME, "
	cQuery += "    ZB_DESC   AS DESCRICAO "
	cQuery += "FROM " + RetSqlName("SZB990") + " "
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY ZB_ID "
    
    cQuery := ChangeQuery(cQuery)
    
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
	While !(cAlias)->(Eof())
		oPatente := JsonObject():New()
		oPatente["codigo"] := (cAlias)->ID_CODIGO
		oPatente["patente"] := AllTrim((cAlias)->NOME)
		oPatente["descricao"] := AllTrim((cAlias)->DESCRICAO)
		
		aAdd(aPatentes, oPatente)
		(cAlias)->(dbSkip())
	EndDo
    
    (cAlias)->(dbCloseArea())
    
    oJsonResponse["success"] := .T.
    oJsonResponse["patentes"] := aPatentes
    
Return oJsonResponse

Method GetAcessosPatente(cPatente) Class PatenteService as json
    Local oJsonResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aAcessos := {}
    Local oAcesso := Nil
    
    If Empty(cPatente)
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Código da patente é obrigatório"
        Return oJsonResponse
    EndIf
    
    cQuery := "SELECT "
    cQuery += "    D.ZD_PATENTE AS PATENTE, "
    cQuery += "    D.ZD_MENU    AS MENU, "
    cQuery += "    M.ZC_DESCRI  AS DESC_MENU, "
    cQuery += "    D.ZD_ACESSO  AS ACESSO "
    cQuery += "FROM " + RetSqlName("SZD") + " D "
    cQuery += "INNER JOIN " + RetSqlName("SZC") + " M ON M.ZC_COD = D.ZD_MENU AND M.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE D.D_E_L_E_T_ = ' ' "
    cQuery += "  AND D.ZD_PATENTE = '" + AllTrim(cPatente) + "' "
    cQuery += "ORDER BY D.ZD_MENU "
    
    cQuery := ChangeQuery(cQuery)
    
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    While !(cAlias)->(Eof())
        oAcesso := JsonObject():New()
        oAcesso["patente"] := AllTrim((cAlias)->PATENTE)
        oAcesso["menu"] := AllTrim((cAlias)->MENU)
        oAcesso["descricao"] := AllTrim((cAlias)->DESC_MENU)
        oAcesso["acesso"] := AllTrim((cAlias)->ACESSO) == "1"
        
        aAdd(aAcessos, oAcesso)
        (cAlias)->(dbSkip())
    EndDo
    
    (cAlias)->(dbCloseArea())
    
    oJsonResponse["success"] := .T.
    oJsonResponse["acessos"] := aAcessos
    
Return oJsonResponse

Method GetAllMenus() Class PatenteService as json
    Local oJsonResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aMenus := {}
    Local oMenu := Nil
    
    cQuery := "SELECT "
    cQuery += "    ZC_COD     AS CODIGO, "
    cQuery += "    ZC_DESCRI  AS DESCRICAO, "
    cQuery += "    ZC_MSBLQL  AS BLOQUEADO "
    cQuery += "FROM " + RetSqlName("SZC") + " "
    cQuery += "WHERE D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY ZC_COD "
    
    cQuery := ChangeQuery(cQuery)
    
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    While !(cAlias)->(Eof())
        oMenu := JsonObject():New()
        oMenu["codigo"] := AllTrim((cAlias)->CODIGO)
        oMenu["descricao"] := AllTrim((cAlias)->DESCRICAO)
        oMenu["bloqueado"] := AllTrim((cAlias)->BLOQUEADO) == "1"
        
        aAdd(aMenus, oMenu)
        (cAlias)->(dbSkip())
    EndDo
    
    (cAlias)->(dbCloseArea())
    
    oJsonResponse["success"] := .T.
    oJsonResponse["menus"] := aMenus
    
Return oJsonResponse

Method ValidarAcesso(oBody) Class PatenteService as json
    Local oJsonResponse := JsonObject():New()
    Local oJson := JsonObject():New()
    Local cUsuario := ""
    Local cMenu := ""
    Local lTemAcesso := .F.
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    
    oJson:FromJson(oBody)
    cUsuario := AllTrim(oJson["usuario"])
    cMenu := AllTrim(oJson["menu"])
    
    If Empty(cUsuario) .Or. Empty(cMenu)
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Usuário e menu são obrigatórios"
        Return oJsonResponse
    EndIf
    
    If Upper(AllTrim(cMenu)) == "HOME" .Or. Upper(AllTrim(cMenu)) == "/HOME"
        oJsonResponse["success"] := .T.
        oJsonResponse["acesso"] := .T.
        Return oJsonResponse
    EndIf
    
    // Primeiro verifica se o usuário tem acesso total (patente com menu 999999)
    cQuery := "SELECT 1 FROM " + RetSqlName("SZD") + " D "
    cQuery += "INNER JOIN " + RetSqlName("SZB") + " B ON B.ZB_COD = D.ZD_PATENTE AND B.D_E_L_E_T_ = ' ' AND B.ZB_MSBLQL <> '1' "
    cQuery += "WHERE D.D_E_L_E_T_ = ' ' "
    cQuery += "  AND D.ZD_MENU = '999999' "
    cQuery += "  AND ( "
    cQuery += "    D.ZD_PATENTE = '" + cUsuario + "' "
    cQuery += "    OR D.ZD_PATENTE IN ( "
    cQuery += "        SELECT USR_GRUPO FROM " + RetSqlName("SYS_USR_GROUPS") + " "
    cQuery += "        WHERE D_E_L_E_T_ = ' ' AND USR_ID = '" + cUsuario + "' "
    cQuery += "    ) "
    cQuery += "    OR D.ZD_PATENTE = ( "
    cQuery += "        SELECT USR_FUNCAO FROM " + RetSqlName("SYS_USUARIO") + " "
    cQuery += "        WHERE D_E_L_E_T_ = ' ' AND USR_ID = '" + cUsuario + "' "
    cQuery += "    ) "
    cQuery += "  ) "
    
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    If !(cAlias)->(Eof())
        lTemAcesso := .T.  // Usuário tem acesso total
    EndIf
    
    (cAlias)->(dbCloseArea())
    
    // Se não tem acesso total, verifica acesso específico ao menu
    If !lTemAcesso
        cAlias := GetNextAlias()
        
        cQuery := "SELECT DISTINCT D.ZD_ACESSO "
        cQuery += "FROM " + RetSqlName("SZD") + " D "
        cQuery += "INNER JOIN " + RetSqlName("SZB") + " B ON B.ZB_COD = D.ZD_PATENTE AND B.D_E_L_E_T_ = ' ' AND B.ZB_MSBLQL <> '1' "
        cQuery += "INNER JOIN " + RetSqlName("SZC") + " C ON C.ZC_COD = D.ZD_MENU AND C.D_E_L_E_T_ = ' ' AND C.ZC_MSBLQL <> '1' "
        cQuery += "WHERE D.D_E_L_E_T_ = ' ' "
        cQuery += "  AND D.ZD_MENU = '" + cMenu + "' "
        cQuery += "  AND D.ZD_ACESSO = '1' "
        cQuery += "  AND ( "
        // Verifica pelo código do usuário
        cQuery += "    D.ZD_PATENTE = '" + cUsuario + "' "
        // Verifica pelos grupos do usuário
        cQuery += "    OR D.ZD_PATENTE IN ( "
        cQuery += "        SELECT USR_GRUPO "
        cQuery += "        FROM " + RetSqlName("SYS_USR_GROUPS") + " "
        cQuery += "        WHERE D_E_L_E_T_ = ' ' "
        cQuery += "          AND USR_ID = '" + cUsuario + "' "
        cQuery += "    ) "
        // Verifica pela função do usuário
        cQuery += "    OR D.ZD_PATENTE = ( "
        cQuery += "        SELECT USR_FUNCAO "
        cQuery += "        FROM " + RetSqlName("SYS_USUARIO") + " "
        cQuery += "        WHERE D_E_L_E_T_ = ' ' "
        cQuery += "          AND USR_ID = '" + cUsuario + "' "
        cQuery += "    ) "
        cQuery += "  ) "
        
        cQuery := ChangeQuery(cQuery)
        
        dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
        
        If !(cAlias)->(Eof())
            lTemAcesso := .T.
        EndIf
        
        (cAlias)->(dbCloseArea())
    EndIf
    
    oJsonResponse["success"] := .T.
    oJsonResponse["acesso"] := lTemAcesso
    oJsonResponse["usuario"] := cUsuario
    oJsonResponse["menu"] := cMenu
    
    If lTemAcesso
        oJsonResponse["message"] := "Usuário tem acesso ao menu"
    Else
        oJsonResponse["message"] := "Usuário não tem acesso ao menu"
    EndIf
    
Return oJsonResponse

Method GetRotasUsuario(oBody) Class PatenteService as json
    Local oJsonResponse := JsonObject():New()
    Local oJson := JsonObject():New()
    Local cUsuario := ""
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aRotas := {}
    Local oRota := Nil
    Local lAcessoTotal := .F.
    Local cAliasCheck := ""
    Local cQueryCheck := ""

    oJson:FromJson(oBody)

	If Empty(oBody) .Or. Empty(oJson["usuario"])
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Código do usuário é obrigatório"
        Return oJsonResponse
    EndIf

    cUsuario := AllTrim(oJson["usuario"])

    cQueryCheck := "SELECT 1 FROM " + RetSqlName("SZD") + " D "
    cQueryCheck += "INNER JOIN " + RetSqlName("SZB") + " B ON B.ZB_COD = D.ZD_PATENTE AND B.D_E_L_E_T_ = ' ' AND B.ZB_MSBLQL <> '1' "
    cQueryCheck += "WHERE D.D_E_L_E_T_ = ' ' "
    cQueryCheck += "  AND D.ZD_MENU = '999999' "
    cQueryCheck += "  AND ( "
    cQueryCheck += "    D.ZD_PATENTE = '" + cUsuario + "' "
    cQueryCheck += "    OR D.ZD_PATENTE IN ( "
    cQueryCheck += "        SELECT USR_GRUPO FROM " + RetSqlName("SYS_USR_GROUPS") + " "
    cQueryCheck += "        WHERE D_E_L_E_T_ = ' ' AND USR_ID = '" + cUsuario + "' "
    cQueryCheck += "    ) "
    cQueryCheck += "    OR D.ZD_PATENTE = ( "
    cQueryCheck += "        SELECT USR_FUNCAO FROM " + RetSqlName("SYS_USUARIO") + " "
    cQueryCheck += "        WHERE D_E_L_E_T_ = ' ' AND USR_ID = '" + cUsuario + "' "
    cQueryCheck += "    ) "
    cQueryCheck += "  ) "

    cQueryCheck := ChangeQuery(cQueryCheck)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQueryCheck), cAliasCheck, .F., .T.)

    If !(cAliasCheck)->(Eof())
        lAcessoTotal := .T.
    EndIf

    (cAliasCheck)->(dbCloseArea())

    // Busca todos os menus que o usuário tem acesso
    cQuery := "SELECT DISTINCT "
    cQuery += "    M.ZC_COD     AS CODIGO, "
    cQuery += "    M.ZC_DESCRI  AS DESCRICAO, "
    cQuery += "    M.ZC_ROTA    AS ROTA, "
    cQuery += "    M.ZC_ICONE   AS ICONE, "
    cQuery += "    M.ZC_ORDEM   AS ORDEM "
    cQuery += "FROM " + RetSqlName("SZC") + " M "
    cQuery += "WHERE M.D_E_L_E_T_ = ' ' "
    cQuery += "  AND M.ZC_MSBLQL <> '1' "

    // Se tem acesso total (999999), retorna TODOS os menus
    If lAcessoTotal
        cQuery += "ORDER BY M.ZC_ORDEM, M.ZC_COD "
    Else
        cQuery += "  AND ( "
        // HOME sempre liberado para todos
        cQuery += "    UPPER(RTRIM(M.ZC_COD)) = 'HOME' "
        // Verifica se o usuário tem acesso através das patentes específicas
        cQuery += "    OR EXISTS ( "
        cQuery += "        SELECT 1 "
        cQuery += "        FROM " + RetSqlName("SZD") + " D "
        cQuery += "        INNER JOIN " + RetSqlName("SZB") + " B ON B.ZB_COD = D.ZD_PATENTE AND B.D_E_L_E_T_ = ' ' AND B.ZB_MSBLQL <> '1' "
        cQuery += "        WHERE D.D_E_L_E_T_ = ' ' "
        cQuery += "          AND D.ZD_MENU = M.ZC_COD "
        cQuery += "          AND D.ZD_ACESSO = '1' "
        cQuery += "          AND ( "
        // Verifica pelo código do usuário
        cQuery += "            D.ZD_PATENTE = '" + cUsuario + "' "
        // Verifica pelos grupos do usuário
        cQuery += "            OR D.ZD_PATENTE IN ( "
        cQuery += "                SELECT USR_GRUPO "
        cQuery += "                FROM " + RetSqlName("SYS_USR_GROUPS") + " "
        cQuery += "                WHERE D_E_L_E_T_ = ' ' "
        cQuery += "                  AND USR_ID = '" + cUsuario + "' "
        cQuery += "            ) "
        // Verifica pela função do usuário
        cQuery += "            OR D.ZD_PATENTE = ( "
        cQuery += "                SELECT USR_FUNCAO "
        cQuery += "                FROM " + RetSqlName("SYS_USUARIO") + " "
        cQuery += "                WHERE D_E_L_E_T_ = ' ' "
        cQuery += "                  AND USR_ID = '" + cUsuario + "' "
        cQuery += "            ) "
        cQuery += "          ) "
        cQuery += "    ) "
        cQuery += "  ) "
        cQuery += "ORDER BY M.ZC_ORDEM, M.ZC_COD "
    EndIf

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)

    While !(cAlias)->(Eof())
        oRota := JsonObject():New()
        oRota["codigo"] := AllTrim((cAlias)->CODIGO)
        oRota["descricao"] := AllTrim((cAlias)->DESCRICAO)
        oRota["rota"] := AllTrim((cAlias)->ROTA)
        oRota["icone"] := AllTrim((cAlias)->ICONE)
        oRota["ordem"] := Val((cAlias)->ORDEM)
        
        aAdd(aRotas, oRota)
        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(dbCloseArea())

    oJsonResponse["success"] := .T.
    oJsonResponse["usuario"] := cUsuario
    oJsonResponse["rotas"] := aRotas
    oJsonResponse["total"] := Len(aRotas)

Return oJsonResponse

