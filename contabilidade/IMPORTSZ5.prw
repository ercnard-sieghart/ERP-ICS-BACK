#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#Include "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"

/*------------------------------------------------------------------------//
//Programa:	 IMPORTSZ5
//Autor:	 Victor Lucas
//Data:		 23/09/2024
//Descricao: Importação de Contabilidade Fluxx.
//------------------------------------------------------------------------*/

User Function IMPORTSZ5()
    Local cTexto
    Local bConfirm
    Local bSair

    Local oDialog
    Local oContainer
    Public cSuccessCount := 0
    Public lTableCleaned := .F.

    Private cPlanilha  := ""
    Public oFile 
    Private aOpcoes := {}
    Private cAbas := ""
    Private dDataIni := sToD("")
    Private dDataFin := sToD("")
     
    Private oTGet1
    Private oTGet2
    Private oTButton1

    
    bConfirm := {|| FwMsgRun(,{|oSay| Iif(MsgYesNo("Tem certeza que deseja importar essa planilha? O conteúdo atual será substituído."),ImportaPlanilha(oContainer, aOpcoes) , NIL)}, 'Aguardando... ', "",) }
    bSair := {|| Iif(MsgYesNo('Você tem certeza que deseja sair da rotina?', 'Sair da rotina'), (oDialog:DeActivate()), NIL) }

    oDialog := FWDialogModal():New()

    oDialog:SetBackground(.T.)
    oDialog:SetTitle('Importação Contabilidade Fluxx')
    oDialog:SetSize(150, 250) 
    oDialog:EnableFormBar(.T.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetEscClose(.F.)  
    oDialog:CreateDialog()
    oDialog:CreateFormBar()
    oDialog:AddButton('Importar', bConfirm, 'Confirmar', , .T., .F., .T.)
    oDialog:AddButton('Sair', bSair, 'Sair', , .T., .F., .T.)
    
    oContainer := TPanel():New( ,,, oDialog:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    cTexto := '• Requisitos do obrigatorios para importação do Arquivo. •'
    cTexto1 := '• Delimitador obrigatório: vírgula (,)'
    cTexto2 := '• Não é permitido: ponto e vírgula (;)'
    cTexto3 := "• Evite caracteres especiais (acentuação, símbolos e emojis)" + CRLF + ;
                "   nos dados e nos nomes de colunas"

    oSay2 := TSay():New(010,010,{||cTexto},oContainer,,,,,,.T.,,,800,20)
    oSay3 := TSay():New(018,010,{||cTexto1},oContainer,,,,,,.T.,,,800,20)
    oSay4 := TSay():New(026,010,{||cTexto2},oContainer,,,,,,.T.,,,800,20)
    oSay5 := TSay():New(034,010,{||cTexto3},oContainer,,,,,,.T.,,,800,20)

    // Adiciona campos para selecionar a planilha
    oSay1 := TSay():New(049,010,{||'Selecione a Planilha:'},oContainer,,,,,,.T.,,,100,9)
    oTGet0 := tGet():New(055,010,{|u| if(PCount()>0,cPlanilha:=u,cPlanilha)},oContainer ,180,9,"",,,,,,,.T.,,, {|| .T. } ,,,,.F.,,,"cPlanilha")

    // Função chamada para selecionar a planilha e obter pastas *
    oTButton1 := TButton():New(055, 195, "Selecionar..." ,oContainer,{|| (cPlanilha:=cGetFile("Arquivos CSV | *.csv*",OemToAnsi("Selecione Diretorio"),,"",.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)),  } , 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    oDialog:Activate()
Return


//----------------------------------------
// Verificar se a planilha foi selecionada.
//----------------------------------------
Static Function ImportaPlanilha(oContainer, aOpcoes)
    Local oFile
    Local aLinhas
    Local nTotLinhas
    Local nCount := 0
    Local aCampos := {}
    Local aDados := {}
    Local aCSV := {}
    Local n, cLinAtu

    If Empty(cPlanilha)
        FWAlertError("Selecione uma planilha antes de importar.", "Atenção")
        Return .F.
    EndIf

    oFile := FWFileReader():New(cPlanilha)

    // Verifica se o arquivo pode ser aberto
    If (oFile:Open())
        
        aLinhas := oFile:GetAllLines()
        nTotLinhas := Len(aLinhas)

        oFile:Close()
        oFile := FWFileReader():New(cPlanilha)
        oFile:Open()
        
        While (oFile:HasLine())        
            nCount ++
            
            // Lê uma linha do arquivo
            cLinAtu := oFile:GetLine()
            cLinAtu := strTran(cLinAtu,";","; ")       
            cLinAtu := FwNoAccent(cLinAtu)

            // Divide a linha em colunas com delimitador ";"
            aDados := StrToKArr2(cLinAtu, ";")
            For n := 1 To Len(aDados)            
                If nCount == 1
                    aAdd(aCampos,Alltrim(aDados[n]))                
                Else                                        
                    aDados[n] := Alltrim(aDados[n])
                Endif 
            Next n 
            
            If nCount < 2
                LOOP
            EndIf 
            aAdd(aDados, nCount)
            aAdd(aCSV, aDados)
        EndDo
        oFile:Close()
        ProcessarDados(oContainer, aCSV)
    Else
        FWAlertError("Não foi possível abrir o arquivo CSV.", "Erro")
        Return .F.
    EndIf

Return 
//----------------------------------------
// Função para processar e importar dados
//----------------------------------------
Static Function ProcessarDados(oContainer, aCSV)
    Local aLista := {}
    Local nLin
    Local aLinha
    Local oJson
    Local nLinhaPer

    nLinhaPer := Len(aCSV)

    For nLin := 1 To nLinhaPer
        aLinha := aCSV[nLin]
        oJson := JsonObject():New() 

        oJson["BaseRequest"]     := aLinha[1]
        oJson["Ano"]             := aLinha[3]
        oJson["Status"]          := aLinha[4]
        oJson["NomeStatus"]      := aLinha[5]
        oJson["FoundingAmounti"] := Val(StrTran(StrTran(aLinha[6], ".", ""), ",", "."))
        oJson["Historico"]       := aLinha[7]
        oJson["FonteRecurso"]    := aLinha[8]
        oJson["ItemContabil"]    := aLinha[9]
        oJson["NomeItem"]        := aLinha[10]
        oJson["PO"]              := aLinha[11]
        oJson["Portfolio"]       := aLinha[12]
        oJson["CentroCusto"]     := aLinha[13]
        oJson["NomeCC"]          := aLinha[14]

        aAdd(aLista, oJson)
    Next

    FinalizaImport(oJson, aLista)
Return 

//----------------------------------------
// Verificar se a importao deve ser concluda
//----------------------------------------
Static Function FinalizaImport(oJson, aLista)

    Local LinTam
    Local i  := 0 
    
    LinTam := Len(aLista)
    TableClean()

    For i := 1 To LinTam

        oJson := aLista[i]

        If Select("SZ5") == 0
            DbUseArea(.T., "TOPCONN", RetSqlName("SZ5"), "SZ5", .F., .T.)
        EndIf
        
        If RecLock("SZ5", .T.)

            //SZ5->Z5_FILIAL     := xFilial("SZ5")
            SZ5->Z5_BASEREQ    := oJson["BaseRequest"]
            SZ5->Z5_ANO        := oJson["Ano"]
            SZ5->Z5_STATUS     := oJson["Status"]
            SZ5->Z5_NSTATUS    := oJson["NomeStatus"]
            SZ5->Z5_AMOUNTI    := oJson["FoundingAmounti"]
            SZ5->Z5_HISTORI    := oJson["Historico"]
            SZ5->Z5_FRECURS    := oJson["FonteRecurso"]
            SZ5->Z5_ITEMCON    := oJson["ItemContabil"]
            SZ5->Z5_NOMEITE    := oJson["NomeItem"]
            SZ5->Z5_PO         := oJson["PO"]
            SZ5->Z5_PORTFOL    := oJson["Portfolio"]
            SZ5->Z5_CC         := oJson["CentroCusto"]
            SZ5->Z5_NOMECC     := oJson["NomeCC"]
            If oJson["ClasseValor"] != Nil
                SZ5->Z5_CVALOR     := oJson["ClasseValor"]
            EndIf

            If oJson["NomeClasse"] != Nil
                SZ5->Z5_NOMECLA    := oJson["NomeClasse"]
            EndIf

            MsUnlock()

        Else
            FWAlertError("Erro ao tentar gravar linha " + AllTrim(Str(i)) + "!", "Erro")
        EndIf

    Next

    FWAlertInfo("Importação Realizada com sucesso!", "Sucesso!")
Return .T.

//--------------------------
// Apaga registro de importações anteriores.
//--------------------------
Static Function TableClean()
    If !lTableCleaned
        cQuery1 := "DELETE FROM " + RetSqlName("SZ5")
        
        If TCSQLExec(cQuery1) == 0
            lTableCleaned = .T.  // Marca que a tabela foi limpa
        Else
            FWAlertError("Não foi possível limpar a tabela SZ5.", "Erro")
        Endif
    Endif
Return

