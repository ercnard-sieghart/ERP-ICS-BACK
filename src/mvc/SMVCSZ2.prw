#INCLUDE "Protheus.ch"
#INCLUDE "Parmtype.ch"
#INCLUDE "FWMVCDef.ch"

User Function MVCSZ2()

	Local aArea := GetArea()
	Local oBrowse := FwMBrowse():New()
    
	oBrowse:SetAlias("SZ2")
	oBrowse:SetMenuDef('MVCSZ2')
    oBrowse:SetDescription("Cadastro de Orçamento")
	
	oBrowse:Activate()
	RestArea(aArea)
return Nil

Static Function MenuDef()

	aRotina := {} 

	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MVCSZ2' 		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MVCSZ2' 		OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir' 	  ACTION 'VIEWDEF.MVCSZ2' 		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MVCSZ2' 		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Copia' 	  ACTION 'VIEWDEF.MVCSZ2'		OPERATION 9 ACCESS 0

Return aRotina
// Criando a Model DEF

Static Function ModelDef()
	Local oModel := Nil
	Local oStSZ2 := FWFormStruct(1,"SZ2")
	
	//Instanciando o modelo de dados
	oModel := MPFormModel():New("ZMODELSZ2", , , ,)
	//Atribuindo formulario para o modelo de dados.
	oModel:AddFields("FORMSZ2",,oStSZ2)
	//chave primaria da rotina
	oModel:SetPrimaryKey({'Z2_FILIAL','Z2_CODORC'})
	
	// Adicionando descricao ao modelo de dados.
	oModel:SetDescription("Cadastro de Orçamento")
	
	oModel:GetModel("FORMSZ2"):SetDescription("Cadastro de Orçamento")
	
Return oModel

//ViewDEf
Static Function ViewDef()
	local oView := Nil
	Local oModel := FWLoadModel("MVCSZ2")
	Local oStSZ2 := FwFormStruct(2,"SZ2")
	
	oView := FWFormView():New() //construindo o modelo de dados
	
	oView:SetModel(oModel) //Passando o modelo de dados informado
	
	oView:AddField("VIEW_SZ2", oStSZ2, "FORMSZ2")
	
	oView:CreateHorizontalBox("TELA",100) //Criando um container com o identificador TELA
	
	oView:EnableTitleView("VIEW_SZ2",'ICS') //Adicionando titulo ao formulário
	
	oView:SetCloseOnOk({||.T.}) //força o fechamento da janela
	
	oView:SetOwnerView("VIEW_SZ2","TELA") //adicionando o formulário da inerface ao container
	
//retornando o objeto view
Return oView
