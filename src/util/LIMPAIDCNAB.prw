#Include "Totvs.ch"
#Include 'Protheus.ch'
#Include 'FWBrowse.ch'
#Include 'TbiConn.ch'
#Include 'RWMAKE.ch'
#Include 'Topconn.ch'
/*------------------------------------------------------------------------//
//Programa:  LIMPAIDCNAB
//Autor:     Victor Lucas
//Data:      18/11/2024
//Descricao: Altera COD CNAB.
//------------------------------------------------------------------------*/
User Function LIMPAIDCNAB()
    Local oDlg        := Nil
    Local cCodigoCNAB := Space(100)
    Local lOk         := .F.
    DEFINE DIALOG oDlg TITLE "Apagar Registros CNAB" SIZE 275, 150
    @ 10, 10 SAY "Digite até 5 Códigos CNAB separados por vírgula:" OF oDlg SIZE 280, 20 PIXEL
    @ 20, 10 GET cCodigoCNAB PICTURE "@!" OF oDlg SIZE 90, 15 PIXEL
    @ 50, 10 BUTTON "Cancelar" ACTION (oDlg:End()) OF oDlg SIZE 40, 15 PIXEL
    @ 50, 60 BUTTON "Confirmar" ACTION (lOk := .T., oDlg:End(), DelCodigoCNAB(cCodigoCNAB)) OF oDlg SIZE 40, 15 PIXEL
    ACTIVATE DIALOG oDlg CENTERED
//--------------------------
// Deleta códigos CNAB
//--------------------------
Static Function DelCodigoCNAB(cCodigoCNAB)
    Local aCodigos := {}
    Local cCodigo
    Local i
    Local nPos
    Local cSubStr
    Local aNaoEncontrados
    If Empty(cCodigoCNAB)
        MsgInfo("O código CNAB não pode ser vazio!")
        Return .F.
    EndIf
    nPos := 1
    While nPos <= Len(cCodigoCNAB)
        // Extrair 10 caracteres e garantir que estamos pegando o código completo
        cSubStr := AllTrim(SubStr(cCodigoCNAB, nPos, 10))
        // Verificar se o código tem exatamente 10 caracteres
        If Len(cSubStr) == 10 .and. ! Empty(cSubStr)
            AAdd(aCodigos, cSubStr)
        EndIf
        // Avançar para o próximo código (10 caracteres para o código e 1 para a vírgula)
        nPos := nPos + 11
        // Se houver vírgula, avançar a posição
        If nPos <= Len(cCodigoCNAB) .and. SubStr(cCodigoCNAB, nPos, 1) == ","
            nPos := nPos + 1
        EndIf
    EndDo

    If Len(aCodigos) > 5
        MsgInfo("Você pode digitar no máximo 5 códigos CNAB!")
        Return .F.
    EndIf
    aNaoEncontrados := VerificarExistenciaCNAB(aCodigos)
    If Len(aNaoEncontrados) > 0
        MsgInfo("Os seguintes códigos CNAB não foram encontrados: " + ArrTokStr(aNaoEncontrados, ", "), ",", Chr(13) + Chr(10))
        Return
    EndIf
    If ! ApMsgYesNo("Deseja alterar o Registro CNAB?", "Atenção")
        Return
    EndIf
        For i := 1 To Len(aCodigos)
            cCodigo := AllTrim(aCodigos[i])
            cQuery := "SELECT E2_IDCNAB FROM " + RetSqlName("SE2") + " WHERE E2_IDCNAB = '" + cCodigo + "'"
            If TCSqlExec(cQuery) == 0
                cUpdateQuery := "UPDATE " + RetSqlName("SE2") + " SET E2_IDCNAB = ' ' WHERE E2_IDCNAB = '" + cCodigo + "'"
                If TCSqlExec(cUpdateQuery) == 0
                    MsgInfo("E2_IDCNAB para o código " + cCodigo + " foi atualizado com sucesso.")
                Else
                    MsgInfo("Erro ao atualizar o E2_IDCNAB para o código " + cCodigo)
                EndIf
            Else                                                                                                                        
                MsgInfo("Código não encontrado: " + cCodigo)
            EndIf
        Next
    VerificarExclusao(aCodigos)
Return
//--------------------------
// Verifica se os códigos foram alterados
//--------------------------
Static Function VerificarExclusao(aCodigos)
    Local aFailCodes := {}
    Local cFailCodesStr := ""
    Local cCodigo
    Local cQuery
    Local aResults
    Local i
    For i := 1 To Len(aCodigos)
        cCodigo := aCodigos[i]
        cQuery := "SELECT E2_IDCNAB FROM " + RetSqlName("SE2") + " WHERE E2_IDCNAB = '" + cCodigo + "'"
        aResults := QryArray(cQuery)
        If Len(aResults) > 0
            AAdd(aFailCodes, cCodigo)
        Else
            MsgInfo("Código CNAB " + cCodigo + " alterado com sucesso.")
        EndIf
    Next
    If Len(aFailCodes) > 0
        For i := 1 To Len(aFailCodes)
            cFailCodesStr += aFailCodes[i] + Chr(13) + Chr(10)
        Next
        MsgInfo("Os seguintes códigos CNAB não foram alterados:" + Chr(13) + Chr(10) + cFailCodesStr)
    Else
        MsgInfo("Todos os códigos CNAB foram alterados com sucesso!")
    EndIf
Return
//--------------------------
// Antes de alterar os códigos CNAB verifica se eles existem na base de dados
//--------------------------
Static Function VerificarExistenciaCNAB(aCodigos)
    Local aNaoEncontrados := {}
    Local cCodigo
    Local cQuery
    Local aResults
    Local i
    For i := 1 To Len(aCodigos)
        cCodigo := aCodigos[i]
        cQuery := "SELECT E2_IDCNAB FROM " + RetSqlName("SE2") + " WHERE E2_IDCNAB = '" + cCodigo + "'"
        aResults := QryArray(cQuery)
        If Len(aResults) == 0
            AAdd(aNaoEncontrados, cCodigo)
        EndIf
    Next
Return aNaoEncontrados
