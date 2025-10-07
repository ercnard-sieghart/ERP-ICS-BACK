#Include "protheus.ch"
#Include "totvs.ch"
#Include "TbiConn.ch"
#Include "topconn.ch"

Class SE5Service
    Static Method GetExtratoBancario(oParams) as json
    Static Method GetBancos() as json
    Static Method GetAgencias(cCodigo) as json
    Static Method GetContas(cCodigo, cAgencia) as json
EndClass

Method GetExtratoBancario(oParams) Class SE5Service as json
    Local oJsonResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aMovimentos := {}
    Local oMovimento := Nil
    Local nTotalEntrada := 0
    Local nTotalSaida := 0
    Local nSaldo := 0
    
    // Monta a query do extrato bancário
    cQuery := "SELECT "
    cQuery += "    M.E5_FILIAL   AS FILIAL, "
    cQuery += "    M.E5_BANCO    AS BANCO, "
    cQuery += "    M.E5_AGENCIA  AS AGENCIA, "
    cQuery += "    M.E5_CONTA    AS CONTA_BANCO, "
    cQuery += "    M.E5_BENEF    AS BENEFICIARIO, "
    cQuery += "    M.E5_TIPODOC  AS TIPO_DOC, "
    cQuery += "    M.E5_HISTOR   AS HISTORICO, "
    cQuery += "    M.E5_DATA     AS DATA_MOV, "
    cQuery += "    M.E5_NATUREZ  AS NATUREZA, "
    cQuery += "    M.E5_DOCUMEN  AS DOCUMENTO, "
    cQuery += "    M.E5_RECPAG   AS RECPAG, "
    cQuery += "    M.E5_VALOR    AS VALOR, "
    cQuery += "    CASE WHEN M.E5_RECPAG = 'R' THEN M.E5_VALOR ELSE 0 END AS ENTRADA, "
    cQuery += "    CASE WHEN M.E5_RECPAG = 'P' THEN M.E5_VALOR ELSE 0 END AS SAIDA, "
    cQuery += "    B.A6_NOME     AS NOME_BANCO "
    cQuery += "FROM " + RetSqlName("SE5") + " M "
    cQuery += "INNER JOIN " + RetSqlName("SA6") + " B "
    cQuery += "    ON B.A6_FILIAL  = M.E5_FILIAL "
    cQuery += "   AND B.A6_COD     = M.E5_BANCO "
    cQuery += "   AND B.A6_AGENCIA = M.E5_AGENCIA "
    cQuery += "   AND B.A6_NUMCON  = M.E5_CONTA "
    cQuery += "   AND B.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE "
    cQuery += "    M.D_E_L_E_T_ = ' ' "
    
    // Filtros dos parâmetros
    If !Empty(oParams["filial"])
        cQuery += "    AND M.E5_FILIAL = '" + oParams["filial"] + "' "
    EndIf
    
    If !Empty(oParams["banco"])
        cQuery += "    AND M.E5_BANCO = '" + oParams["banco"] + "' "
    EndIf
    
    If !Empty(oParams["agencia"])
        cQuery += "    AND M.E5_AGENCIA = '" + oParams["agencia"] + "' "
    EndIf
    
    If !Empty(oParams["conta"])
        cQuery += "    AND M.E5_CONTA = '" + oParams["conta"] + "' "
    EndIf
    
    If !Empty(oParams["dataInicio"]) .And. !Empty(oParams["dataFim"])
        cQuery += "    AND M.E5_DATA BETWEEN '" + oParams["dataInicio"] + "' AND '" + oParams["dataFim"] + "' "
    EndIf
    
    // Filtros opcionais
    If !Empty(oParams["natureza"])
        cQuery += "    AND M.E5_NATUREZ = '" + oParams["natureza"] + "' "
    EndIf
    
    If !Empty(oParams["tipoDoc"])
        cQuery += "    AND M.E5_TIPODOC = '" + oParams["tipoDoc"] + "' "
    EndIf
    
    cQuery += "ORDER BY M.E5_FILIAL, M.E5_BANCO, M.E5_AGENCIA, M.E5_CONTA, M.E5_DATA, M.E5_DOCUMEN "
    
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    // Verifica se encontrou dados
    If (cAlias)->(Eof())
        oJsonResponse["success"] := .T.
        oJsonResponse["message"] := "Nenhum movimento encontrado para os filtros informados"
        oJsonResponse["total"] := 0
        oJsonResponse["totalEntrada"] := 0
        oJsonResponse["totalSaida"] := 0
        oJsonResponse["saldo"] := 0
        oJsonResponse["movimentos"] := {}
        (cAlias)->(dbCloseArea())
        Return oJsonResponse
    EndIf
    
    // Processa os movimentos
    (cAlias)->(dbGoTop())
    While !(cAlias)->(Eof())
        
        oMovimento := JsonObject():New()
        oMovimento["filial"] := AllTrim((cAlias)->FILIAL)
        oMovimento["banco"] := AllTrim((cAlias)->BANCO)
        oMovimento["agencia"] := AllTrim((cAlias)->AGENCIA)
        oMovimento["conta"] := AllTrim((cAlias)->CONTA_BANCO)
        oMovimento["nomeBanco"] := AllTrim((cAlias)->NOME_BANCO)
        oMovimento["beneficiario"] := AllTrim((cAlias)->BENEFICIARIO)
        oMovimento["tipoDoc"] := AllTrim((cAlias)->TIPO_DOC)
        oMovimento["historico"] := AllTrim((cAlias)->HISTORICO)
        oMovimento["dataMov"] := DtoS(StoD((cAlias)->DATA_MOV))
        oMovimento["natureza"] := AllTrim((cAlias)->NATUREZA)
        oMovimento["documento"] := AllTrim((cAlias)->DOCUMENTO)
        oMovimento["recPag"] := AllTrim((cAlias)->RECPAG)
        oMovimento["valor"] := (cAlias)->VALOR
        oMovimento["entrada"] := (cAlias)->ENTRADA
        oMovimento["saida"] := (cAlias)->SAIDA
        
        // Acumula totais
        nTotalEntrada += (cAlias)->ENTRADA
        nTotalSaida += (cAlias)->SAIDA
        
        AAdd(aMovimentos, oMovimento)
        
        (cAlias)->(dbSkip())
    EndDo
    
    (cAlias)->(dbCloseArea())
    
    // Calcula saldo
    nSaldo := nTotalEntrada - nTotalSaida
    
    // Monta resposta
    oJsonResponse["success"] := .T.
    oJsonResponse["message"] := "Extrato bancário obtido com sucesso"
    oJsonResponse["total"] := Len(aMovimentos)
    oJsonResponse["totalEntrada"] := nTotalEntrada
    oJsonResponse["totalSaida"] := nTotalSaida
    oJsonResponse["saldo"] := nSaldo
    oJsonResponse["filtros"] := oParams
    oJsonResponse["movimentos"] := aMovimentos
    
Return oJsonResponse

Method GetBancos() Class SE5Service as json
    Local oJsonResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aBancos := {}
    Local oBanco := Nil
    
    cQuery := "SELECT DISTINCT "
    cQuery += "    A6_COD AS CODIGO, "
    cQuery += "    A6_AGENCIA AS AGENCIA, "
    cQuery += "    A6_NUMCON AS CONTA, "
    cQuery += "    A6_NOME AS NOME, "
    cQuery += "    A6_NREDUZ AS NOME_REDUZIDO "
    cQuery += "FROM " + RetSqlName("SA6") + " "
    cQuery += "WHERE D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY A6_COD, A6_AGENCIA, A6_NUMCON "
    
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    (cAlias)->(dbGoTop())
    While !(cAlias)->(Eof())
        
        oBanco := JsonObject():New()
        oBanco["codigo"] := AllTrim((cAlias)->CODIGO)
        oBanco["agencia"] := AllTrim((cAlias)->AGENCIA)
        oBanco["conta"] := AllTrim((cAlias)->CONTA)
        oBanco["nome"] := AllTrim((cAlias)->NOME)
        oBanco["nomeReduzido"] := AllTrim((cAlias)->NOME_REDUZIDO)
        
        AAdd(aBancos, oBanco)
        
        (cAlias)->(dbSkip())
    EndDo
    
    (cAlias)->(dbCloseArea())
    
    oJsonResponse["success"] := .T.
    oJsonResponse["message"] := "Bancos obtidos com sucesso"
    oJsonResponse["total"] := Len(aBancos)
    oJsonResponse["bancos"] := aBancos
    
Return oJsonResponse

Method GetAgencias(oBody) Class SE5Service as json
    Local oJsonResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aAgencias := {}
    Local oAgencia := Nil
    Local oJson := JsonObject():New()
    Local cCodigo := ""
    Local cAgencia := ""

    oJson := JsonObject():New()
    oJson:FromJson(oBody)  
    cCodigo := oJson["banco"]
    cAgencia := oJson["agencia"]

    If Empty(cCodigo)
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Código do banco é obrigatório"
        oJsonResponse["total"] := 0
        oJsonResponse["agencias"] := {}
        Return oJsonResponse
    EndIf

    If !Empty(cAgencia)
        oJsonResponse := SE5Service():GetContas(oBody)
        Return oJsonResponse
    EndIf
    
    cQuery := "SELECT DISTINCT "
    cQuery += "    A6_COD AS CODIGO_BANCO, "
    cQuery += "    A6_AGENCIA AS AGENCIA "
    cQuery += "FROM " + RetSqlName("SA6") + " "
    cQuery += "WHERE D_E_L_E_T_ = ' ' "
    cQuery += "  AND A6_COD = '" + AllTrim(cCodigo) + "' "
    cQuery += "ORDER BY A6_AGENCIA "
    
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    If (cAlias)->(Eof())
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Nenhuma agência encontrada para o banco: " + AllTrim(cCodigo)
        oJsonResponse["total"] := 0
        oJsonResponse["agencias"] := {}
        (cAlias)->(dbCloseArea())
        Return oJsonResponse
    EndIf
    
    (cAlias)->(dbGoTop())
    While !(cAlias)->(Eof())
        
        oAgencia := JsonObject():New()
        oAgencia["COD"] := AllTrim((cAlias)->CODIGO_BANCO)
        oAgencia["AGENCIAS"] := AllTrim((cAlias)->AGENCIA)
        
        AAdd(aAgencias, oAgencia)
        
        (cAlias)->(dbSkip())
    EndDo
    
    (cAlias)->(dbCloseArea())
    
    oJsonResponse["success"] := .T.
    oJsonResponse["message"] := "Agências obtidas com sucesso"
    oJsonResponse["total"] := Len(aAgencias)
    oJsonResponse["agencias"] := aAgencias
    
Return oJsonResponse

Method GetContas(oBody) Class SE5Service as json
    Local oJsonResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aContas := {}
    Local oConta := Nil
    Local oJson := JsonObject():New()
    Local cCodigo := ""
    Local cAgencia := ""

    oJson := JsonObject():New()
    oJson:FromJson(oBody)  
    cCodigo := oJson["banco"]
    cAgencia := oJson["agencia"]

    If Empty(cCodigo) .AND. Empty(cAgencia)
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Código do banco e da agência são obrigatórios"
        oJsonResponse["total"] := 0
        oJsonResponse["contas"] := {}
        Return oJsonResponse
    EndIf
    
    cQuery := "SELECT DISTINCT "
    cQuery += "    A6_COD AS CODIGO_BANCO, "
    cQuery += "    A6_AGENCIA AS AGENCIA, "
    cQuery += "    A6_NUMCON AS CONTA "
    cQuery += "FROM " + RetSqlName("SA6") + " "
    cQuery += "WHERE D_E_L_E_T_ = ' ' "
    cQuery += "  AND A6_COD = '" + AllTrim(cCodigo) + "' "
    cQuery += "  AND A6_AGENCIA = '" + AllTrim(cAgencia) + "' "
    cQuery += "ORDER BY A6_NUMCON "
    
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    If (cAlias)->(Eof())
        oJsonResponse["success"] := .F.
        oJsonResponse["message"] := "Nenhuma conta encontrada para o banco: " + AllTrim(cCodigo) + " agência: " + AllTrim(cAgencia)
        oJsonResponse["total"] := 0
        oJsonResponse["contas"] := {}
        (cAlias)->(dbCloseArea())
        Return oJsonResponse
    EndIf
    
    (cAlias)->(dbGoTop())
    While !(cAlias)->(Eof())
        
        oConta := JsonObject():New()

        oConta["contas"] := AllTrim((cAlias)->CONTA)
        
        AAdd(aContas, oConta)
        
        (cAlias)->(dbSkip())
    EndDo
    
    (cAlias)->(dbCloseArea())
    
    oJsonResponse["success"] := .T.
    oJsonResponse["message"] := "Contas obtidas com sucesso"
    oJsonResponse["total"] := Len(aContas)
    oJsonResponse["banco"] := AllTrim(cCodigo)
    oJsonResponse["agencia"] := AllTrim(cAgencia)
    oJsonResponse["contas"] := aContas
    
Return oJsonResponse
