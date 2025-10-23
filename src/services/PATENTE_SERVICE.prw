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
    Local oSecurity := SecurityService():New()
    Local aPatentesUsr := {}

    If oSecurity:IsAdmin() .Or. oSecurity:HasFullAccess()
        cQuery := "SELECT "
        cQuery += "    ZC_MENU  AS MENU, "
        cQuery += "    ZC_DESC  AS DESCRICAO, "
        cQuery += "    ZC_ROTA  AS ROTA "
        cQuery += "FROM " + RetSqlName("SZC990") + " "
        cQuery += "WHERE D_E_L_E_T_ = ' ' "
        cQuery += "ORDER BY R_E_C_N_O_, ZC_ID "

        cQuery := ChangeQuery(cQuery)

        dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)

        While !(cAlias)->(Eof())
            oMenu := JsonObject():New()
            oMenu["menu"]      := AllTrim((cAlias)->MENU)
            oMenu["descricao"] := AllTrim((cAlias)->DESCRICAO)
            oMenu["rota"]      := AllTrim((cAlias)->ROTA)

            aAdd(aMenus, oMenu)
            (cAlias)->(dbSkip())
        EndDo

        (cAlias)->(dbCloseArea())

        oJsonResponse["success"] := .T.
        oJsonResponse["all_menus"] := .T.
        oJsonResponse["menus"] := aMenus

        Return oJsonResponse
    Else
        aPatentesUsr := PatentesUsr()

        If Len(aPatentesUsr) == 0
            oJsonResponse["success"] := .F.
            oJsonResponse["message"] := "Usuário não possui patentes"
            Return oJsonResponse
        EndIf

        aMenus := MenusPorPatentes(aPatentesUsr)

        aRotas := Rotas(aMenus)

        oJsonResponse["success"] := .T.
        oJsonResponse["all_menus"] := .F.
        oJsonResponse["menus"] := aRotas
    EndIf
Return oJsonResponse    

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

Static Function PatentesUsr()
    Local aPatentesUsr := {}
    Local cQueryPat := ""
    Local cAliasPat := GetNextAlias()

    cQueryPat := "SELECT ZE_PATENTE FROM " + RetSqlName("SZE") + " WHERE D_E_L_E_T_ = ' ' AND ZE_USR = '" + __cUserID + "'"
    cQueryPat := ChangeQuery(cQueryPat)

    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQueryPat), cAliasPat, .F., .T.)
    While !(cAliasPat)->(Eof())
        aAdd(aPatentesUsr, AllTrim((cAliasPat)->ZE_PATENTE))
        (cAliasPat)->(dbSkip())
    EndDo
    (cAliasPat)->(dbCloseArea())

Return aPatentesUsr

Static Function MenusPorPatentes(aPatentesUsr)
    Local aMenus := {}
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local cIn := ""
    Local i := 0
    Local cMenu := ""

    If ValType(aPatentesUsr) <> "A" .Or. Len(aPatentesUsr) == 0
        Return aMenus
    EndIf

    For i := 1 To Len(aPatentesUsr)
        cIn += ValToSQL(AllTrim(aPatentesUsr[i])) + ","
    Next

    If Len(cIn) == 0
        Return aMenus
    EndIf

    cIn := SubStr(cIn, 1, Len(cIn) - 1)

    cQuery := "SELECT ZD_PATENTE, ZD_MENU, ZD_DESC FROM " + RetSqlName("SZD") + " "
    cQuery += "WHERE D_E_L_E_T_ = ' ' AND ZD_PATENTE IN (" + cIn + ") "
    cQuery += "ORDER BY ZD_MENU"

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    While !(cAlias)->(Eof())
        cMenu := AllTrim((cAlias)->ZD_MENU)
        If AScan(aMenus, cMenu) == 0
            aAdd(aMenus, cMenu)
        EndIf
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())

Return aMenus

Static Function Rotas(aMenus)
    Local aRotas := {}
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local i := 0
    Local cIn := ""

    If ValType(aMenus) <> "A" .Or. Len(aMenus) == 0
        Return aRotas
    EndIf

    For i := 1 To Len(aMenus)
        cIn += ValToSQL(AllTrim(aMenus[i])) + ","
    Next
    
    If Len(cIn) == 0
        Return aRotas
    EndIf
    cIn := SubStr(cIn, 1, Len(cIn) - 1)

    cQuery := "SELECT ZC_MENU, ZC_ROTA, ZC_DESC FROM " + RetSqlName("SZC") + " "
    cQuery += "WHERE D_E_L_E_T_ = ' ' AND ZC_ID IN (" + cIn + ") "
    
    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    While !(cAlias)->(Eof())
        aAdd(aRotas, AllTrim((cAlias)->ZC_MENU))
        aAdd(aRotas, AllTrim((cAlias)->ZC_DESC))
        aAdd(aRotas, AllTrim((cAlias)->ZC_ROTA))
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())

Return aRotas   
