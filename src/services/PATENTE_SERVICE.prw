#Include "protheus.ch"
#Include "totvs.ch"
#Include "TbiConn.ch"
#Include "topconn.ch"

Class PatenteService
    Static Method GetAllPatentes() as json
    Static Method GetAcessosPatente(cPatente) as json
    Static Method RetornaMenus() as json
    Static Method VerificaAcessoMenu(oBody) as json
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
	cQuery += "FROM " + RetSqlName("SZB") + " "
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

Method RetornaMenus() Class PatenteService as json
    Local oJsonResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aMenus := {}
    Local oMenu := Nil
    Local cUser := AllTrim(__cUserID)
    Local cAliasCheck := GetNextAlias()
    Local cQueryCheck := ""
    Local oSecurity := SecurityService():New()

    If oSecurity:IsAdmin() .Or. oSecurity:HasFullAccess()
        cQuery := "SELECT "
        cQuery += "    ZC_COD    AS CODIGO, "
        cQuery += "    ZC_DESCRI AS DESCRICAO, "
        cQuery += "    ZC_ROTA   AS ROTA, "
        cQuery += "    ZC_ICONE  AS ICONE, "
        cQuery += "    ZC_ORDEM  AS ORDEM "
        cQuery += "FROM " + RetSqlName("SZC") + " "
        cQuery += "WHERE D_E_L_E_T_ = ' ' "
        cQuery += "  AND ZC_MSBLQL <> '1' "
        cQuery += "ORDER BY ZC_ORDEM, ZC_COD "

        cQuery := ChangeQuery(cQuery)

        dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)

        While !(cAlias)->(Eof())
            oMenu := JsonObject():New()
            oMenu["codigo"] := AllTrim((cAlias)->CODIGO)
            oMenu["descricao"] := AllTrim((cAlias)->DESCRICAO)
            oMenu["rota"] := AllTrim((cAlias)->ROTA)
            oMenu["icone"] := AllTrim((cAlias)->ICONE)
            oMenu["ordem"] := Val((cAlias)->ORDEM)

            aAdd(aMenus, oMenu)
            (cAlias)->(dbSkip())
        EndDo

        (cAlias)->(dbCloseArea())

        oJsonResponse["success"] := .T.
        oJsonResponse["menus"] := aMenus

        Return oJsonResponse
    Else
        // Verifica se o usuário possui alguma patente na SZE
        cQueryCheck := "SELECT 1 FROM " + RetSqlName("SZE") + " WHERE D_E_L_E_T_ = ' ' AND ZE_USR = '" + cUser + "' AND ALLTRIM(ZE_PATENTE) <> '' "

        cQueryCheck := ChangeQuery(cQueryCheck)
        dbUseArea(.T., "TOPCONN", TCGenQry(,, cQueryCheck), cAliasCheck, .F., .T.)

        If (cAliasCheck)->(Eof())
            (cAliasCheck)->(dbCloseArea())
            oJsonResponse["success"] := .F.
            oJsonResponse["message"] := "Usuário não possui patentes"
            Return oJsonResponse
        EndIf

        (cAliasCheck)->(dbCloseArea())

        // Busca menus com base nas patentes do usuário (via SZE -> ZE_PATENTE -> SZD)
        cQuery := "SELECT DISTINCT "
        cQuery += "    M.ZC_COD    AS CODIGO, "
        cQuery += "    M.ZC_DESCRI AS DESCRICAO, "
        cQuery += "    M.ZC_ROTA   AS ROTA, "
        cQuery += "    M.ZC_ICONE  AS ICONE, "
        cQuery += "    M.ZC_ORDEM  AS ORDEM "
        cQuery += "FROM " + RetSqlName("SZC") + " M "
        cQuery += "WHERE M.D_E_L_E_T_ = ' ' "
        cQuery += "  AND M.ZC_MSBLQL <> '1' "
        cQuery += "  AND ( UPPER(RTRIM(M.ZC_COD)) = 'HOME' OR EXISTS ( "
        cQuery += "      SELECT 1 FROM " + RetSqlName("SZD") + " D "
        cQuery += "      INNER JOIN " + RetSqlName("SZB") + " B ON B.ZB_COD = D.ZD_PATENTE AND B.D_E_L_E_T_ = ' ' AND B.ZB_MSBLQL <> '1' "
        cQuery += "      INNER JOIN " + RetSqlName("SZE") + " E ON E.ZE_PATENTE = D.ZD_PATENTE AND E.D_E_L_E_T_ = ' ' AND E.ZE_USR = '" + cUser + "' "
        cQuery += "      WHERE D.D_E_L_E_T_ = ' ' AND D.ZD_MENU = M.ZC_COD AND D.ZD_ACESSO = '1' "
        cQuery += "  ) ) "
        cQuery += "ORDER BY M.ZC_ORDEM, M.ZC_COD "

        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)

        While !(cAlias)->(Eof())
            oMenu := JsonObject():New()
            oMenu["codigo"] := AllTrim((cAlias)->CODIGO)
            oMenu["descricao"] := AllTrim((cAlias)->DESCRICAO)
            oMenu["rota"] := AllTrim((cAlias)->ROTA)
            oMenu["icone"] := AllTrim((cAlias)->ICONE)
            oMenu["ordem"] := Val((cAlias)->ORDEM)

            aAdd(aMenus, oMenu)
            (cAlias)->(dbSkip())
        EndDo

        (cAlias)->(dbCloseArea())

        oJsonResponse["success"] := .T.
        oJsonResponse["menus"] := aMenus

        Return oJsonResponse
    Endif
    
Return 

Method VerificaAcessoMenu(oBody) Class PatenteService as json
    Local oJsonResponse := JsonObject():New()
    Local oJson := JsonObject():New()
    Local cUsuario := ""
    Local cMenu := ""
    Local lTemAcesso := .F.
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local oSecurity := SecurityService():New()

    // Recebe e valida o body
    If Empty(oBody)
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Body é obrigatório"
        Return oJsonResponse
    EndIf

    oJson:FromJson(oBody)

    cUsuario := AllTrim(oJson["usuario"]) // usuário a verificar
    cMenu := AllTrim(oJson["menu"])       // código/rota do menu

    If Empty(cUsuario) .Or. Empty(cMenu)
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Usuário e menu são obrigatórios"
        Return oJsonResponse
    EndIf

    // Se o usuário é admin ou tem acesso total, retorna acesso positivo
    If oSecurity:IsAdmin() .Or. oSecurity:HasFullAccess()
        oJsonResponse["success"] := .T.
        oJsonResponse["hasAccess"] := .T.
        Return oJsonResponse
    EndIf

    // Verifica via query EXISTS se o usuário (ou grupos/função) possui acesso ao menu
    cQuery := "SELECT 1 FROM " + RetSqlName("SZD") + " D "
    cQuery += " INNER JOIN " + RetSqlName("SZB") + " B ON B.ZB_COD = D.ZD_PATENTE AND B.D_E_L_E_T_ = ' ' AND B.ZB_MSBLQL <> '1' "
    cQuery += " WHERE D.D_E_L_E_T_ = ' ' "
    cQuery += "   AND D.ZD_MENU = " + ValToSQL(cMenu)
    cQuery += "   AND D.ZD_ACESSO = '1' "
    cQuery += "   AND ( D.ZD_PATENTE = " + ValToSQL(cUsuario)
    cQuery += "       OR D.ZD_PATENTE IN (SELECT USR_GRUPO FROM " + RetSqlName("SYS_USR_GROUPS") + " WHERE D_E_L_E_T_ = ' ' AND USR_ID = " + ValToSQL(cUsuario) + ")"
    cQuery += "       OR D.ZD_PATENTE = (SELECT USR_FUNCAO FROM " + RetSqlName("SYS_USUARIO") + " WHERE D_E_L_E_T_ = ' ' AND USR_ID = " + ValToSQL(cUsuario) + ") )"

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    If !(cAlias)->(Eof())
        lTemAcesso := .T.
    EndIf
    (cAlias)->(dbCloseArea())

    oJsonResponse["success"] := .T.
    oJsonResponse["hasAccess"] := lTemAcesso
    If .T. == lTemAcesso
        oJsonResponse["message"] := "Usuário tem acesso ao menu"
    Else
        oJsonResponse["message"] := "Usuário não possui acesso ao menu"
    EndIf

Return oJsonResponse
