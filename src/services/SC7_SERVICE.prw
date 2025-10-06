#Include "protheus.ch"
#Include "totvs.ch"
#Include "FWBrowse.ch"
#Include "TbiConn.ch"
#Include "topconn.ch"
#Include "rwmake.ch"

Class SC7Service
    Static Method GetPedidos()
    // Static Method DuplicatePedido(cSourceNum, cSourceItem, oNewData) 
EndClass

Method GetPedidos() Class SC7Service 
	Local aJsonResp := {}
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local aFields := {}
	Local aImportantFields := {}
	Local nField
	Local aRow := {}
	Local xValue
	Local cFieldName := ""
	Local nFieldPos := 0
	Local cFieldType := ""
	Local oJsonResponse := JsonObject():New()
	Local oJsonItem := Nil
	Local nItem := 0
	Local nCampo := 0

	AAdd(aImportantFields, "C7_NUM")
	AAdd(aImportantFields, "C7_ITEM")
	AAdd(aImportantFields, "C7_PRODUTO")
	AAdd(aImportantFields, "C7_DESCRI")
	AAdd(aImportantFields, "C7_QUANT")
	AAdd(aImportantFields, "C7_PRECO")
	AAdd(aImportantFields, "C7_TOTAL")
	AAdd(aImportantFields, "C7_EMISSAO")
	AAdd(aImportantFields, "C7_DATPRF")
	AAdd(aImportantFields, "C7_FORNECE")
	AAdd(aImportantFields, "C7_CONTATO")
	AAdd(aImportantFields, "C7_LOJA")
	AAdd(aImportantFields, "C7_ITEMCTA")
	AAdd(aImportantFields, "C7_CONTA")
	AAdd(aImportantFields, "C7_CC")
	AAdd(aImportantFields, "C7_OBS")


	DbSelectArea("SC7")
	aFields := SC7->(DbStruct())
	
	cQuery := "SELECT "
	For nField := 1 To Len(aImportantFields)
		cQuery += aImportantFields[nField]
		If nField < Len(aImportantFields)
			cQuery += ", "
		EndIf
	Next

	cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
	cQuery += "WHERE SC7.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY C7_NUM, C7_ITEM "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)

    (cAlias)->(dbGoTop())
    
    While !(cAlias)->(Eof())
		aRow := {}
		
        For nField := 1 To Len(aImportantFields)
            cFieldName := aImportantFields[nField]
            xValue := (cAlias)->(FieldGet(nField))
            
            nFieldPos := AScan(aFields, {|x| x[1] == cFieldName})
            cFieldType := If(nFieldPos > 0, aFields[nFieldPos][2], "C")
            
            Do Case
                Case cFieldType == "C"
                    xValue := AllTrim(xValue)
                Case cFieldType == "N"
                    
                Case cFieldType == "D"
                    xValue := Date(xValue) 
                Case cFieldType == "L"
                    
            EndCase
            
            AAdd(aRow, {cFieldName, xValue})
        Next

        AAdd(aJsonResp, aRow)
        
        (cAlias)->(dbSkip())
    EndDo
    
    (cAlias)->(dbCloseArea())
    
    oJsonResponse["success"] := .T.
    oJsonResponse["message"] := "Pedidos de compra obtidos com sucesso"
    oJsonResponse["total"] := Len(aJsonResp)
    oJsonResponse["items"] := {}
    
    For nItem := 1 To Len(aJsonResp)
        oJsonItem := JsonObject():New()
        
        For nCampo := 1 To Len(aJsonResp[nItem])
            oJsonItem[aJsonResp[nItem][nCampo][1]] := aJsonResp[nItem][nCampo][2]
        Next
        
        AAdd(oJsonResponse["items"], oJsonItem)
    Next
    
Return oJsonResponse

/**
Method DuplicatePedido(cSourceNum, cSourceItem, oNewData) Class SC7Service
    Local oResponse := JsonObject():New()
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aFields := {}
    Local nField := 0
    Local cNewNum := ""
    Local cNewItem := ""
    Local lSuccess := .F.
    
    cQuery := "SELECT * FROM " + RetSqlName("SC7") + " "
    cQuery += "WHERE C7_NUM = '" + cSourceNum + "' "
    cQuery += "AND C7_ITEM = '" + cSourceItem + "' "
    cQuery += "AND D_E_L_E_T_ = ' ' "
    
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    If (cAlias)->(Eof())
        oResponse["success"] := .F.
        oResponse["message"] := "Registro origem não encontrado"
        (cAlias)->(dbCloseArea())
        Return oResponse
    EndIf
    
    cNewNum := oNewData["newNum"]
    cNewItem := oNewData["newItem"]
    
    If Empty(cNewNum)
        cNewNum := ProxNum()
    EndIf
    
    If Empty(cNewItem)
        cNewItem := "01"
    EndIf
    
    Begin Transaction
        
        DbSelectArea("SC7")
        SC7->(DbSetOrder(1))
        
        If SC7->(DbSeek(xFilial("SC7") + cNewNum + cNewItem))
            oResponse["success"] := .F.
            oResponse["message"] := "Registro já existe com esse número/item"
            DisarmTransaction()
        Else
            SC7->(RecLock("SC7", .T.))
            
            aFields := SC7->(DbStruct())
            For nField := 1 To Len(aFields)
                cFieldName := aFields[nField][1]
                
                Do Case
                    Case cFieldName == "C7_NUM"
                        SC7->C7_NUM := cNewNum
                    Case cFieldName == "C7_ITEM"  
                        SC7->C7_ITEM := cNewItem
                    Case cFieldName == "C7_EMISSAO"
                        SC7->C7_EMISSAO := Date()
                    Case SubStr(cFieldName, 1, 2) == "C7"
                        xValue := (cAlias)->(FieldGet((cAlias)->(FieldPos(cFieldName))))
                        SC7->(FieldPut(SC7->(FieldPos(cFieldName)), xValue))
                EndCase
            Next
            
            If ValType(oNewData["modifications"]) == "O"
                If !Empty(oNewData["modifications"]["C7_QUANT"])
                    SC7->C7_QUANT := oNewData["modifications"]["C7_QUANT"]
                EndIf
                If !Empty(oNewData["modifications"]["C7_DATPRF"])
                    SC7->C7_DATPRF := CtoD(oNewData["modifications"]["C7_DATPRF"])
                EndIf
            EndIf
            
            SC7->(MsUnlock())
            lSuccess := .T.
        EndIf
        
    End Transaction
    
    (cAlias)->(dbCloseArea())
    
    If lSuccess
        oResponse["success"] := .T.
        oResponse["message"] := "Pedido duplicado com sucesso"
        oResponse["newRecord"] := {"C7_NUM": cNewNum, "C7_ITEM": cNewItem}
    EndIf
    
Return oResponse
