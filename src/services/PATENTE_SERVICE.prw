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
    Local oSecurity := SecurityService():New()
    Local aPatentesUsr := {}
    Local lAcesso := .F.
    Local cIDMenu := ""
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local cIn := ""
    Local i := 0
    
    If oSecurity:IsAdmin() .Or. oSecurity:HasFullAccess()
        oJsonResponse["message"] := "Acesso autorizado"
        oJsonResponse["acess"] := .T.
        Return oJsonResponse
    EndIf

    aPatentesUsr := PatentesUsr()

    If !Empty(oBody)
        cIDMenu := AllTrim(oBody:ID)

        For i := 1 To Len(aPatentesUsr)
            cIn += ValToSQL(AllTrim(aPatentesUsr[i])) + ","
        Next

        If Len(cIn) == 0
            oJsonResponse["message"] := "Acesso negado"
            oJsonResponse["acess"] :=  lAcesso
            Return oJsonResponse
        EndIf

        cIn := SubStr(cIn, 1, Len(cIn) - 1)

        cQuery := "SELECT ZD_PATENTE FROM " + RetSqlName("SZD") + " "
        cQuery += "WHERE D_E_L_E_T_ = ' ' AND ZD_MENU = " + ValToSQL(AllTrim(cIDMenu)) + " AND ZD_PATENTE IN (" + cIn + ") "

        cQuery := ChangeQuery(cQuery)

        dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)

        If !(cAlias)->(Eof())
            lAcesso := .T.
        EndIf

        If lAcesso == .T.
            oJsonResponse["message"] := "Acesso autorizado"
            oJsonResponse["acess"] := lAcesso
        Else
            oJsonResponse["message"] := "Acesso negado"
            oJsonResponse["acess"] := lAcesso
        EndIf

        (cAlias)->(dbCloseArea())

    Else
        oJsonResponse["message"] := "ID do menu é obrigatório"
        oJsonResponse["acess"] := lAcesso
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
    Local oMenu 

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

    cQuery := "SELECT ZC_ID, ZC_MENU, ZC_ROTA FROM " + RetSqlName("SZC") + " "
    cQuery += "WHERE D_E_L_E_T_ = ' ' AND ZC_ID IN (" + cIn + ") "
    
    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    While !(cAlias)->(Eof())
        oMenu := JsonObject():New()
        oMenu["id"]        := AllTrim((cAlias)->ZC_ID)
        oMenu["menu"]      := AllTrim((cAlias)->ZC_MENU)
        oMenu["rota"]      := AllTrim((cAlias)->ZC_ROTA)

        aAdd(aRotas, oMenu)
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())

Return aRotas
